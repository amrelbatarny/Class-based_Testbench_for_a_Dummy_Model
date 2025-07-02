/***********************************************************************
 * Author : Amr El Batarny
 * File   : testbench_pkg.svh
 * Brief  : Package wrapper — includes all testbench SVH files.
 ***********************************************************************/

package testbench_pkg;
	`include "report_object.svh"
	`include "packet.svh"
	`include "driver.svh"
	`include "monitor.svh"
	`include "scoreboard.svh"
	`include "../dut/dut_model.svh"
	`include "testbench.svh"
endpackage : testbench_pkg