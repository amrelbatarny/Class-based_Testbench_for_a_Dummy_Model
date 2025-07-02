vlib work
vlog bfm.sv testbench_pkg.sv top.sv +define+SIM
vsim -voptargs=+acc -nodpiexports -sv_seed random work.top -classdebug
add wave sim:/top/bfm/clk
.vcop Action toggleleafnames
run -all