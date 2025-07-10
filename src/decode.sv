module decode (
	clk,
	reset,
	Op,
	Funct,
	Rd,
	FlagW,
	PCS,
	NextPC,
	RegW,
	RegW2,
	MemW,
	IRWrite,
	AdrSrc,
	ResultSrc,
	ALUSrcA,
	ALUSrcB,
	ImmSrc,
	RegSrc,
	ALUControl
);
	input wire clk;
	input wire reset;
	input wire [1:0] Op;
	input wire [5:0] Funct;
	input wire [3:0] Rd;

	// Salidas
	output wire [1:0] FlagW;
	output wire PCS;
	output wire NextPC;
	output wire RegW;
	output wire RegW2;
	output wire MemW;
	output wire IRWrite;
	output wire AdrSrc;
	output wire [1:0] ResultSrc;
	output wire [1:0] ALUSrcA;
	output wire [1:0] ALUSrcB;
	output wire [1:0] ImmSrc;
	output wire [1:0] RegSrc;
	output wire [3:0] ALUControl;

	// Señales internas
	wire Branch;
	wire ALUOp;
	reg [1:0] flagw_reg;
	reg [3:0] alu_reg;

	// Asignación de salida FlagW y ALUControl desde registro interno
	assign FlagW = flagw_reg;
	assign ALUControl = alu_reg;

	// Máquina de estados principal
	mainfsm fsm(
		.clk(clk),
		.reset(reset),
		.Op(Op),
		.Funct(Funct),
		.IRWrite(IRWrite),
		.AdrSrc(AdrSrc),
		.ALUSrcA(ALUSrcA),
		.ALUSrcB(ALUSrcB),
		.ResultSrc(ResultSrc),
		.NextPC(NextPC),
		.RegW(RegW),
		.RegW2(RegW2),
		.MemW(MemW),
		.Branch(Branch),
		.ALUOp(ALUOp)
	);

	// ALU Decoder
	always @(*) begin
		if (ALUOp) begin
			case (Funct[4:1])
				4'b0100: alu_reg = 4'b0000; // add
				4'b0010: alu_reg = 4'b0001; // sub
				4'b0000: alu_reg = 4'b0010; // and
				4'b1100: alu_reg = 4'b0011; // orr
				4'b0001: alu_reg = 4'b0100; // mul
				4'b1001: alu_reg = 4'b0101; // umul
				4'b1010: alu_reg = 4'b0110; // smul
				4'b1000: alu_reg = 4'b0111; // div
				4'b1101: alu_reg = 4'b1000; // mov
				default: alu_reg = 4'bxxx;
			endcase
			flagw_reg[1] = Funct[0];
			flagw_reg[0] = Funct[0] & ((alu_reg == 4'b0000) | (alu_reg == 4'b0001));
		end
		else begin
			alu_reg = 4'b0000;
			flagw_reg = 2'b00;
		end
	end

	// Lógica para PC
	assign PCS = ((Rd == 4'b1111) & RegW) | Branch;

	// Decodificador de instrucciones
	assign ImmSrc = Op;
	assign RegSrc[0] = (Op == 2'b10);
	assign RegSrc[1] = (Op == 2'b01);

endmodule

