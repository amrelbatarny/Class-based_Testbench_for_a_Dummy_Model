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