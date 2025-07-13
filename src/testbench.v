`timescale 1ns / 1ns

module testbench();
	reg clk;
	reg reset;
	wire [3:0] anode;
	wire [7:0] catode;
	processor proc(
		.clk(clk),
		.reset(reset),
		.anode(anode),
		.catode(catode)
	);
	initial begin
		reset <= 1;
		#(22)
			;
		reset <= 0;
	end
	always begin
		clk <= 1;
		#(5)
			;
		clk <= 0;
		#(5)
			;
	end
endmodule