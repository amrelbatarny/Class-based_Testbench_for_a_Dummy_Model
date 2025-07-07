/***********************************************************************
 * Author : Amr El Batarny
 * File   : testbench.svh
 * Brief  : Testbench class — instantiates driver, DUT model, monitor,
 * 			and scoreboard.
 ***********************************************************************/

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

	bit is_small_len;

	function new (report_object rep, virtual BFM b, bit is_small_len);
		this.report_h = rep;
		this.bfm = b;
		this.is_small_len = is_small_len;
	endfunction : new
	
	task execute(bit[8:0] n_pkt);
   		mbox_in			= new();
   		mbox_out		= new();
		mbox_mon		= new();
		mbox_drv		= new();
		
		dut_h			= new(report_h, mbox_in,  mbox_out);
		driver_h		= new(report_h, mbox_in,  mbox_drv, bfm, is_small_len);
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