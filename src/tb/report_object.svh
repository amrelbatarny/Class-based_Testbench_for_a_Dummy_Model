/***********************************************************************
 * Author : Amr El Batarny
 * File   : report_object.svh
 * Brief  : Report object — accumulates pass/fail counters and prints
 * 			summary.
 ***********************************************************************/

class report_object;
	int test_num;
	int driven_count;
	int monitored_count;
	int compared_count;
	int match_count;
	int mismatch_count;

	function new(int test_num);
		this.test_num = test_num;
	endfunction

	function void report_results();
		$display("");
		$display("========== TEST [%0d] SUMMARY ==========", test_num);
		$display("  Packets driven    : %0d", driven_count);
		$display("  Packets monitored : %0d", monitored_count);
		$display("  Packets compared  : %0d", compared_count);
		$display("  MATCHES           : %0d", match_count);
		$display("  MISMATCHES        : %0d", mismatch_count);
		$display("========================================");
	endfunction : report_results
endclass : report_object