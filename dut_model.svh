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