module alu(
    input [31:0] a, b,
    input [3:0] ALUControl,
    output reg [31:0] Result,
    output reg [31:0] Result2,
    output wire [3:0] ALUFlags
);

    wire neg, zero, carry, overflow;
    wire [31:0] condinvb;
    wire [32:0] sum;
    wire [63:0] mulres;
    wire [32:0] divrem;
    wire [31:0] divres;

    assign condinvb = ALUControl[0] ? ~b : b;
    assign sum = a + condinvb + ALUControl[0];

    mul mulinst (
        .a(a),
        .b(b),
        .issigned(ALUControl[1]),
        .result(mulres)
    );

    div divinst (
        .a(a),
        .b(b),
        .rem(divrem),
        .q(divres)
    );

    always @(*) begin
        case (ALUControl)
            4'b0000: Result = sum;                      
            4'b0001: Result = sum;                    
            4'b0010: Result = a & b;                    
            4'b0011: Result = a | b;                    
            4'b0100: Result = mulres[31:0];             // mul
            4'b0101: begin                              // umul
                Result = mulres[63:32];
                Result2 = mulres[31:0];
            end
            4'b0110: begin                              // smul
                Result = mulres[63:32];
                Result2 = mulres[31:0];
            end
            4'b0111: Result = divres;                   // div
            4'b1000: Result = b;                        // mov
            default: Result = 32'bx;
        endcase
    end

    assign neg      = Result[31];
    assign zero     = (Result == 32'b0);
    assign carry    = (ALUControl[3:1] == 3'b000) & sum[32];
    assign overflow = (ALUControl[3:1] == 3'b000) & ~(a[31] ^ b[31] ^ ALUControl[0]) & (a[31] ^ sum[31]);
    assign ALUFlags = {neg, zero, carry, overflow};
endmodule