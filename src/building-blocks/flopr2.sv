module flopr2 (
	clk,
	reset,
	d0,
	q0,
    d1,
    q1
);
	parameter WIDTH = 8;
	input wire clk;
	input wire reset;
	input wire [WIDTH - 1:0] d0;
	output reg [WIDTH - 1:0] q0;
    input wire [WIDTH - 1:0] d1;
    output reg [WIDTH - 1:0] q1;
	always @(posedge clk or posedge reset)
		if (reset)
			q0 <= 0;
			q1 <= 0;
		else
			q0 <= d0;
            q1 <= d1;
endmodule