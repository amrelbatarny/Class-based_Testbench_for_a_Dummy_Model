interface BFM ();
	bit clk;
	
	initial begin
		forever #1 clk = !clk;
	end
endinterface