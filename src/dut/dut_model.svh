/***********************************************************************
 * Author : Amr El Batarny
 * File   : dut_model.svh
 * Brief  : DUT model class — reorders packets with a configurable delay.
 ***********************************************************************/

class dut_model;
	mailbox 		m_in, m_out;
	packet 			pkt_in1, pkt_in2, pkt_in;
	bit [8:0]		delay_1, delay_2;
	report_object	rep;

	function new(report_object rep, mailbox mbox_in, mailbox mbox_out);
		this.rep	= rep;
		this.m_in	= mbox_in;
		this.m_out	= mbox_out;
	endfunction

	task execute();
		$display("[%0t] DUT: executing", $time);
		m_in.get(pkt_in1);
		m_in.get(pkt_in2);
		delay_1 = $urandom_range(500, 600);
		delay_2 = $urandom_range(300, 400);
		fork
			begin
				#delay_1 m_out.put(pkt_in1);
			end

			begin
				#delay_2 m_out.put(pkt_in2);
			end
			
			begin
				forever begin
					m_in.get(pkt_in);
					m_out.put(pkt_in);
				end
			end
		join
	endtask : execute
endclass : dut_model