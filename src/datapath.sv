module datapath (
	clk,
	reset,
	Adr,
	WriteData,
	ReadData,
	Instr,
	ALUFlags,
	PCWrite,
	RegWrite,
	RegWrite2,
	IRWrite,
	AdrSrc,
	RegSrc,
	ALUSrcA,
	ALUSrcB,
	ResultSrc,
	ImmSrc,
	ALUControl,
	Half,
	Result
);
	input wire clk;
	input wire reset;
	output wire [31:0] Adr;
	output wire [31:0] WriteData;
	input wire [31:0] ReadData;
	output wire [31:0] Instr;
	output wire [3:0] ALUFlags;
	input wire PCWrite;
	input wire RegWrite;
	input wire RegWrite2;
	input wire IRWrite;
	input wire AdrSrc;
	input wire [1:0] RegSrc;
	input wire [1:0] ALUSrcA;
	input wire [1:0] ALUSrcB;
	input wire [1:0] ResultSrc;
	input wire [1:0] ImmSrc;
	input wire [3:0] ALUControl;
	input wire Half;
	output wire[31:0] Result;
	wire [31:0] PCNext;
	wire [31:0] PC;
	wire [31:0] ExtImm;
	wire [31:0] SrcA;
	wire [31:0] SrcB;
	wire [31:0] Result;
	wire [31:0] Data;
	wire [31:0] RD1;
	wire [31:0] RD2;
	wire [31:0] A;
	wire [31:0] ALUResult;
	wire [31:0] ALUResult2;
	wire [31:0] ALUOut;
	wire [31:0] FPUOut;
	wire [31:0] FPU16Out;
	wire [31:0] FPUResult;
	wire [3:0] RA1;
	wire [3:0] RA2;

	flopenr #(32) pcreg(
		.clk(clk),
		.reset(reset),
        .en(PCWrite),
		.d(Result),
		.q(PC)
	);

    mux2 #(32) adrmux(
        .d0(PC),
        .d1(Result),
        .s(AdrSrc),
        .y(Adr)
    );

    flopenr #(32) irreg(
        .clk(clk),
        .reset(reset),
        .en(IRWrite),
        .d(ReadData),
        .q(Instr)
    );

    flopr #(32) datareg(
        .clk(clk),
        .reset(reset),
        .d(ReadData),
        .q(Data)
    );

    mux2 #(4) ra1mux(
        .d0(Instr[19:16]),
        .d1(4'd15), // 15
        .s(RegSrc[0]),
        .y(RA1)
    );

    mux2 #(4) ra2mux(
        .d0(Instr[3:0]),
        .d1(Instr[15:12]),
        .s(RegSrc[1]),
        .y(RA2)
    );

    regfile rf(
        .clk(clk),
        .we3(RegWrite),
        .we4(RegWrite2),
        .ra1(RA1),
        .ra2(RA2),
        .wa3(Instr[15:12]),
        .wa4(Instr[11:8]),
        .wd3(Result),
        .wd4(ALUResult2),
        .r15(Result),
        .rd1(RD1),
        .rd2(RD2)
    );

    extend ext(
		.Instr(Instr[23:0]),
		.ImmSrc(ImmSrc),
		.ExtImm(ExtImm)
	);

	flopr2 #(32) rdreg(
		.clk(clk),
		.reset(reset),
		.d0(RD1),
		.q0(A),
		.d1(RD2),
		.q1(WriteData)
	);

	mux2 #(32) srcamux(
		.d0(A),
		.d1(PC),
		.s(ALUSrcA),
		.y(SrcA)
	);

	mux3 #(32) srcbmux(
		.d0(WriteData),
		.d1(ExtImm),
		.d2(32'd4), // 4
		.s(ALUSrcB),
		.y(SrcB)
	);

	alu alu(
		.a(SrcA),
		.b(SrcB),
		.ALUControl(ALUControl),
		.Result(ALUResult),
		.Result2(ALUResult2),
		.ALUFlags(ALUFlags)
	);

	fpu fpu(
		.a(SrcA),
		.b(SrcB),
		.FPUControl(Instr[21]),
		.Result(FPUOut)
	);

	fpu16 fpu16(
		.a(SrcA),
		.b(SrcB),
		.FPUControl(Instr[21]),
		.Result(FPU16Out)
	);

	mux2 #(32) fpumux(
		.d0(FPUOut),
		.d1(FPU16Out),
		.s(Half),
		.y(FPUResult)
	);

	flopr #(32) aluresreg(
		.clk(clk),
		.reset(reset),
		.d(ALUResult),
		.q(ALUOut)
	);

	mux4 #(32) resmux(
		.d0(ALUOut),
		.d1(Data),
		.d2(ALUResult),
		.d3(FPUResult),
		.s(ResultSrc),
		.y(Result)
	);
endmodule
