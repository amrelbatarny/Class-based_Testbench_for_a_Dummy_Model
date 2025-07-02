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