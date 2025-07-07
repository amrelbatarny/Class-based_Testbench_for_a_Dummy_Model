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
	int test_idx, num_test;
	string test_name;
	bit is_rand_num_test, is_small_len;

	initial begin
		test_name = "";

		if($value$plusargs("TEST_NAME=%s", test_name)) begin
			if(test_name == "test_small_len")
				is_small_len = 1;
		end	else begin
			test_name = "default_test";
		end

		if($value$plusargs("NUM_TEST=%0d", num_test))
			is_rand_num_test = 1;

		report_h = new(is_rand_num_test, num_test, test_name);

		report_h.pre_test_report();
		
		repeat(num_test) begin
			report_h.new_test_init();
			testbench_h	= new(report_h, bfm, is_small_len);
			n_pkt = $urandom_range(1, 256);
			testbench_h.execute(n_pkt);
		end
		report_h.report_suite_summary();
		$stop;
	end
endmodule : top