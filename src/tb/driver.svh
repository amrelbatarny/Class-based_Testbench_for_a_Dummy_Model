/***********************************************************************
 * Author : Amr El Batarny
 * File   : driver.svh
 * Brief  : Driver class — generates and sends randomized packets.
 ***********************************************************************/

class driver;
	virtual BFM bfm;

	mailbox			m, m_drv;
	packet 			pkt;
	bit				finished;
	report_object	rep;
	int				n_cycles;
	bit 			is_small_len;

	function new(report_object rep, mailbox mbox, mailbox mbox_drv, virtual BFM b, bit is_small_len);
		this.rep			= rep;
		this.m				= mbox;
		this.m_drv			= mbox_drv;
		this.bfm			= b;
		this.is_small_len	= is_small_len;
	endfunction

	task execute(bit[8:0] n_pkt);
		$display("[%0t] DRIVER: executing with n_pkt: %0d", $time, n_pkt);
		repeat(n_pkt) begin
			@(negedge bfm.clk);
			pkt = new();
			if(is_small_len)
				assert(pkt.randomize() with { data.size() inside {[2:6]}; });
			else // default
				assert(pkt.randomize());
			m.put(pkt);
			m_drv.put(pkt);
			rep.driven_count++;
			n_cycles = $urandom_range(pkt.n, 400);
			repeat (n_cycles) @(negedge bfm.clk);
		end
		finished = 1;
	endtask : execute
endclass : driver