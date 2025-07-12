module mainfsm (
	clk,
	reset,
	Op,
	Funct,
	IRWrite,
	AdrSrc,
	ALUSrcA,
	ALUSrcB,
	ResultSrc,
	NextPC,
	RegW,
	RegW2,
	MemW,
	Branch,
	ALUOp,
	Half
);
	input wire clk;
	input wire reset;
	input wire [1:0] Op;
	input wire [5:0] Funct;
	output wire IRWrite;
	output wire AdrSrc;
	output wire [1:0] ALUSrcA;
	output wire [1:0] ALUSrcB;
	output wire [1:0] ResultSrc;
	output wire NextPC;
	output wire RegW;
	output wire RegW2;
	output wire MemW;
	output wire Branch;
	output wire ALUOp;
	output wire Half;
	reg [3:0] state;
	reg [3:0] nextstate;
	reg [14:0] controls;
	localparam [3:0] FETCH = 0;
  	localparam [3:0] DECODE = 1;
	localparam [3:0] MEMADR = 2;
    localparam [3:0] MEMRD = 3;
    localparam [3:0] MEMWB = 4;
    localparam [3:0] MEMWRITE = 5;
  	localparam [3:0] EXECUTER = 6;
	localparam [3:0] EXECUTEI = 7;
    localparam [3:0] ALUWB = 8;
  	localparam [3:0] BRANCH = 9;
	localparam [3:0] UNKNOWN = 10;
    localparam [3:0] ALUWB2 = 11;
    localparam [3:0] FPUWB = 12;
    localparam [3:0] FPU16WB = 13;

	// state register
	always @(posedge clk or posedge reset)
		if (reset)
			state <= FETCH;
		else
			state <= nextstate;

  	// next state logic
	always @(*)
		casex (state)
			FETCH: nextstate = DECODE;
			DECODE:
				case (Op)
					2'b00:
						if (Funct[5])
							nextstate = EXECUTEI;
						else
							nextstate = EXECUTER;
					2'b01: nextstate = MEMADR;
					2'b10: nextstate = BRANCH;
					default: nextstate = UNKNOWN;
				endcase
			EXECUTER:
				if (Funct[4:1] == 4'b1001 | Funct[4:1] == 4'b1010)
					nextstate = ALUWB2;
				else if (Funct[4:1] == 4'b1110 | Funct[4:1] == 4'b1111)
					nextstate = FPUWB;
				else if (Funct[4:1] == 4'b0110 | Funct[4:1] == 4'b0111)
					nextstate = FPU16WB;
				else
					nextstate = ALUWB;
			EXECUTEI: 
				if (Funct[4:1] == 4'b1001 | Funct[4:1] == 4'b1010)
					nextstate = ALUWB2;
				else if (Funct[4:1] == 4'b1110 | Funct[4:1] == 4'b1111)
					nextstate = FPUWB;
				else if (Funct[4:1] == 4'b0110 | Funct[4:1] == 4'b0111)
					nextstate = FPU16WB;
				else
					nextstate = ALUWB;
			MEMADR:
              if (Funct[0])
                nextstate = MEMRD;
          	  else
                nextstate = MEMWRITE;
			MEMRD:
              	nextstate = MEMWB;
			default: nextstate = FETCH;
		endcase

	// state-dependent output logic
	always @(*)
		case (state)
			FETCH: controls    = 15'b100010100110000;
			DECODE: controls   = 15'b000000100110000;
			EXECUTER: controls = 15'b000000000000100;
			EXECUTEI: controls = 15'b000000000001100;
			ALUWB: controls    = 15'b000100000000000;
			FPUWB: controls    = 15'b000100110000000;
			FPU16WB: controls  = 15'b000100110000001;
			ALUWB2: controls   = 15'b000100000000010;
			MEMADR: controls   = 15'b000000000001000;
			MEMWRITE: controls = 15'b001001000000000;
			MEMRD: controls    = 15'b000000000000000;
			MEMWB: controls    = 15'b000100010000000;
			BRANCH: controls   = 15'b010000100001000;
			default: controls  = 15'bxxxxxxxxxxxxxxx;
		endcase
    //         0       0      0     0      0        0       00         00       00      0      0	 0
	assign {NextPC, Branch, MemW, RegW, IRWrite, AdrSrc, ResultSrc, ALUSrcA, ALUSrcB, ALUOp, RegW2, Half} = controls;
endmodule