/***********************************************************************
 * Author : Amr El Batarny
 * File   : top.sv
 * Brief  : Top-level module — drives multiple test iterations.
 ***********************************************************************/

module top;
	import testbench_pkg::*;

	BFM bfm();
	testbench testbench_h;
	report_object report_h;
	bit[8:0] n_pkt;	// Number of packets generated with each test
	int num_test;

	initial begin
		repeat(3) begin
			num_test++;
			report_h = new(num_test); // Passing the test number to be displayed in the report
			testbench_h	= new(report_h, bfm);
			n_pkt = $urandom_range(1, 256);
			testbench_h.execute(n_pkt);
		end
		$stop;
	end
endmodule : top