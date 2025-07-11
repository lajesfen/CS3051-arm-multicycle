module processor (
	clk,
	reset,
    anode,
    catode
);
	input wire clk;
	input wire reset;
    output wire[3:0] anode,
    output wire[7:0] catode
	
    wire [31:0] WriteData;
	wire [31:0] Adr;
	wire MemWrite;
    wire [31:0] Result;

    wire scl_clk;

    clkdivider #(4) sc(
        .clk(clk),
        .reset(reset),
        .t(scl_clk)
    );

	top top(
		.clk(scl_clk),
		.reset(reset),
		.WriteData(WriteData),
		.Adr(Adr),
		.MemWrite(MemWrite),
        .Result(Result)
	);

    hexdisplay hexdisp(
		.clk(clk),
		.reset(reset),
		.data(Result[15:0]),
		.anode(anode),
		.catode(catode)
	);
endmodule