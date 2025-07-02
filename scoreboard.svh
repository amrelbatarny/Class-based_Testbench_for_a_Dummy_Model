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