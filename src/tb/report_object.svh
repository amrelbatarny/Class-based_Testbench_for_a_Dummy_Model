/***********************************************************************
 * Author : Amr El Batarny
 * File   : report_object.svh
 * Brief  : Report object — accumulates pass/fail counters and prints
 * 			summary.
 ***********************************************************************/

class report_object;
	string test_name;
	bit is_rand_num_test;

	int num_test;
	int test_idx;
	int driven_count, driven_count_total;
	int monitored_count, monitored_count_total;
	int compared_count, compared_count_total;
	int match_count, match_count_total;
	int mismatch_count, mismatch_count_total;

	function new(bit is_rand_num_test, int num_test, string test_name);
		this.is_rand_num_test	= is_rand_num_test;
		this.num_test			= num_test;
		this.test_name			= test_name;
	endfunction : new

	function void pre_test_report();
		driven_count_total		= 0;
		monitored_count_total	= 0;
		compared_count_total	= 0;
		match_count_total		= 0;
		mismatch_count_total	= 0;

		$display("");

		$display("========= Test name: %s =========", test_name);

		if (!is_rand_num_test) begin
			$display("  Running fixed test count: %0d tests", num_test);
		end else begin
			$display("  Randomizing test count: %0d tests", num_test);
		end

		$display("===========================================");

		$display("");
	endfunction : pre_test_report

	function void new_test_init();
		test_idx++;
		driven_count	= 0;	
		monitored_count	= 0;	
		compared_count	= 0;	
		match_count		= 0;
		mismatch_count	= 0;	
	endfunction : new_test_init

	function void report_results();
		$display("");
		$display("=========== TEST [%0d] SUMMARY ===========", test_idx);
		$display("  Packets driven    : %0d", driven_count);
		$display("  Packets monitored : %0d", monitored_count);
		$display("  Packets compared  : %0d", compared_count);
		$display("  MATCHES           : %0d", match_count);
		$display("  MISMATCHES        : %0d", mismatch_count);
		$display("==========================================");
		
		update_total();
	endfunction : report_results

	function void update_total();
		driven_count_total		= driven_count_total	+ driven_count;
		monitored_count_total	= monitored_count_total	+ monitored_count;
		compared_count_total	= compared_count_total	+ compared_count;
		match_count_total		= match_count_total		+ match_count;
		mismatch_count_total	= mismatch_count_total	+ mismatch_count;
	endfunction : update_total

	function void report_suite_summary();
		$display("");
		$display("======== TEST SUITE SUMMARY (%0d tests executed) ========", num_test);
		$display("  Test name               : %s", test_name);
		$display("  Total packets driven    : %0d", driven_count_total);
		$display("  Total packets monitored : %0d", monitored_count_total);
		$display("  Total packets compared  : %0d", compared_count_total);
		$display("  Total MATCHES           : %0d", match_count_total);
		$display("  Total MISMATCHES        : %0d", mismatch_count_total);
		$display("========================================================");
	endfunction : report_suite_summary
endclass : report_object