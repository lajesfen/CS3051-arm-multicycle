module condlogic (
	clk,
	reset,
	Cond,
	ALUFlags,
	FlagW,
	PCS,
	NextPC,
	RegW,
	MemW,
	PCWrite,
	RegWrite,
	MemWrite
);
	input wire clk;
	input wire reset;
	input wire [3:0] Cond;
	input wire [3:0] ALUFlags;
	input wire [1:0] FlagW;
	input wire PCS;
	input wire NextPC;
	input wire RegW;
	input wire MemW;
	output wire PCWrite;
	output wire RegWrite;
	output wire MemWrite;
	wire [1:0] FlagWrite;
	wire [3:0] Flags;
	wire CondEx;
    wire CondExNext;
    wire PCSrc;

    // Delay writing flags until ALUWB state
	flopr #(2) flagwritereg(
		.clk(clk),
		.reset(reset),
		.d(FlagW & {2 {CondExNext}}),
		.q(FlagWrite)
	);

    flopr #(1) condexreg(
        .clk(clk),
        .reset(reset),
        .d(CondExNext),
        .q(CondEx)
    );

    flopenr #(2) flagreg1(
        .clk(clk),
        .reset(reset),
        .en(FlagWrite[1]),
        .d(ALUFlags[3:2]),
        .q(Flags[3:2])
    );

    flopenr #(2) flagreg0(
        .clk(clk),
        .reset(reset),
        .en(FlagWrite[0]),
        .d(ALUFlags[1:0]),
        .q(Flags[1:0])
    );

    condcheck cc(
        .Cond(Cond),
        .Flags(Flags),
        .CondEx(CondExNext)
    );

    assign FlagWrite = FlagW & {2 {CondExNext}};
	assign RegWrite = RegW & CondEx;
	assign MemWrite = MemW & CondEx;
	assign PCSrc = PCS & CondEx;
    assign PCWrite = PCSrc | NextPC;

endmodule