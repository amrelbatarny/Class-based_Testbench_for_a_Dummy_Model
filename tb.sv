package testbench_pkg;
	class report_object;
		int test_num;
		int driven_count;
		int monitored_count;
		int compared_count;
		int match_count;
		int mismatch_count;

		function new(int test_num);
			this.test_num = test_num;
		endfunction

		function void report_results();
			$display("");
			$display("========== TEST [%0d] SUMMARY ==========", test_num);
			$display("  Packets driven    : %0d", driven_count);
			$display("  Packets monitored : %0d", monitored_count);
			$display("  Packets compared  : %0d", compared_count);
			$display("  MATCHES           : %0d", match_count);
			$display("  MISMATCHES        : %0d", mismatch_count);
			$display("========================================");
		endfunction : report_results
	endclass : report_object

	class packet;
		rand int n;			// Packet Size
		rand byte data[];	// Payload Data
		rand byte id;		// Packet ID

		constraint c {
			n inside {[10:100]};
			data.size() == n;
			unique {id};
		}
	endclass : packet

	class driver;
		virtual BFM bfm;

		mailbox			m, m_drv;
		packet 			pkt;
		bit				finished;
		report_object	rep;

		function new(report_object rep, mailbox mbox, mailbox mbox_drv, virtual BFM b);
			this.rep	= rep;
			this.m		= mbox;
			this.m_drv	= mbox_drv;
			this.bfm	= b;
		endfunction

		task execute(bit[8:0] n_pkt);
			$display("[%0t] DRIVER: executing with n_pkt: %0d", $time, n_pkt);
			repeat(n_pkt) begin
				@(negedge bfm.clk);
				pkt = new();
				assert(pkt.randomize());
				m.put(pkt);
				m_drv.put(pkt);
				rep.driven_count++;
				repeat (pkt.n) @(negedge bfm.clk);
			end
			finished = 1;
		endtask : execute
	endclass : driver

	class monitor;
		mailbox			m, m_mon;
		packet			pkt;
		report_object	rep;

		function new(report_object rep, mailbox mbox, mailbox mbox_mon);
			this.rep	= rep;
			this.m		= mbox;
			this.m_mon	= mbox_mon;
		endfunction

		task execute();
			$display("[%0t] MONITOR: executing", $time);
				forever begin
				m.get(pkt);
				m_mon.put(pkt);
				rep.monitored_count++;
			end
		endtask : execute
	endclass : monitor

class scoreboard;
	// Incoming mailboxes
	mailbox mbox_exp, mbox_act;

	// Store packets by ID until both sides have arrived
	packet exp_map [byte], act_map [byte];

	report_object rep;

	bit finished, driver_finished;

	virtual BFM bfm;

	function new(report_object rep, mailbox m_drv, mailbox m_mon, virtual BFM b);
		this.rep		= rep;
		this.mbox_exp	= m_drv;   // expected (driver) side
		this.mbox_act	= m_mon;   // actual   (monitor) side
		this.bfm		= b;
	endfunction
	
	task execute();
		$display("[%0t] SCOREBOARD: executing", $time);

		fork
			// Expected Packet Path
			begin
				packet p;
				forever begin
					mbox_exp.get(p);
					exp_map[p.id] = p;
					// $display("[%0t] SCOREBOARD: got EXP ID=%0d", $time, p.id);
					
					// if its actual peer is already here, compare and clean up
					if (act_map.exists(p.id)) begin
						compare_and_cleanup(p.id);
					end
				end
			end

			// Actual Packet Path
			begin
				packet p;
				forever begin
					mbox_act.get(p);
					act_map[p.id] = p;
					// $display("[%0t] SCOREBOARD: got ACT ID=%0d", $time, p.id);

					// if its expected peer is already here, compare and clean up
					if (exp_map.exists(p.id)) begin
						compare_and_cleanup(p.id);
					end
				end
			end
			
			// Watcher
			begin
				wait(driver_finished);
				repeat(5) @(negedge bfm.clk);
				finished = 1;
			end
		join_none
	endtask : execute

	// Compare, report, and delete both entries for a given packet ID
	function void compare_and_cleanup(byte id);
		packet e = exp_map[id];
		packet a = act_map[id];

		if (e.data != a.data) begin
		  $error("[%0t] MISMATCH ID=%0d exp.len=%0d act.len=%0d",
		         $time, id, e.n, a.n);
		  rep.mismatch_count++;
		end else begin
		  // $display("[%0t] MATCH    ID=%0d len=%0d", $time, id, e.n);
		  rep.match_count++;
		end

		exp_map.delete(id);
		act_map.delete(id);
		rep.compared_count++;
	endfunction : compare_and_cleanup	
endclass : scoreboard

	class dut_model;
		mailbox 		m_in, m_out;
		packet 			pkt_in1, pkt_in2;
		bit [8:0]		delay;
		report_object	rep;

		function new(report_object rep, mailbox mbox_in, mailbox mbox_out);
			this.rep	= rep;
			this.m_in	= mbox_in;
			this.m_out	= mbox_out;
		endfunction

		task execute();
			$display("[%0t] DUT: executing", $time);
			m_in.get(pkt_in1);
			delay = $urandom_range(300, 500);
			fork
				#delay m_out.put(pkt_in1);
				forever begin
					m_in.get(pkt_in2);
					m_out.put(pkt_in2);
				end
			join
		endtask : execute
	endclass : dut_model

	class testbench;
		virtual BFM bfm;
		
		// DUT Model
		dut_model	dut_h;
		
		// Testbench components
		report_object	report_h;
		driver			driver_h;
		monitor			monitor_h;
		scoreboard		scoreboard_h;

		// Mailboxes
		mailbox		mbox_in, mbox_out;		// DUT model mailboxes
		mailbox		mbox_mon, mbox_drv;		// Driver and monitor mailboxes for the scoreboard

		function new (report_object rep, virtual BFM b);
			this.report_h = rep;
			this.bfm = b;
		endfunction : new
		
   		task execute(bit[8:0] n_pkt);
   			mbox_in			= new();
   			mbox_out		= new();
			mbox_mon		= new();
			mbox_drv		= new();
			
			dut_h			= new(report_h, mbox_in,  mbox_out);
			driver_h		= new(report_h, mbox_in,  mbox_drv, bfm);
			monitor_h		= new(report_h, mbox_out, mbox_mon);
			scoreboard_h	= new(report_h, mbox_drv, mbox_mon, bfm);

			fork : exec_group
				scoreboard_h.execute();
				driver_h.execute(n_pkt);
				dut_h.execute();
				monitor_h.execute();
			join_none
				wait(driver_h.finished);
				scoreboard_h.driver_finished = 1;
				wait(scoreboard_h.finished);
				disable exec_group;
				report_h.report_results();
		endtask : execute
	endclass : testbench
endpackage : testbench_pkg

interface BFM ();
	bit clk;
	
	initial begin
		forever #1 clk = !clk;
	end
endinterface

module top;
	import testbench_pkg::*;

	BFM bfm();

	testbench testbench_h;

	report_object report_h;

	bit[8:0] n_pkt; // Number of packets generated with each test

	int num_test;

	initial begin
		repeat(3) begin
			num_test++;
			report_h = new(num_test);
			testbench_h	= new(report_h, bfm);
			n_pkt = $urandom_range(1, 256);
			testbench_h.execute(n_pkt);
		end
		$stop;
	end
endmodule : top