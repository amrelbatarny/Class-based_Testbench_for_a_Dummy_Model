vlib work
vlog -f src_files.f -mfcu +define+SIM
vsim -voptargs=+acc -nodpiexports -sv_seed random work.top -classdebug +NUM_TEST=3 +TEST_NAME=test_small_len
# add wave sim:/top/bfm/clk
# .vcop Action toggleleafnames
run -all