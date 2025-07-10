module fpdecoder(
    input [31:0] instr,
    output reg sign,
    output reg [7:0] exponent,
    output reg [22:0] fraction
);
    wire zero, inf, nan;
    assign zero = (instr[30:23] == 8'd0) && (instr[22:0] == 23'd0);
    assign inf = (instr[30:23] == 8'd255) && (instr[22:0] == 23'd0);
    assign nan = (instr[30:23] == 8'd255) && (instr[22:0] != 23'd0);

    always @(*) begin
        if (zero) begin
            sign = instr[31];
            exponent = 8'b00000000;
            fraction = 23'b0;
        end else if (inf) begin
            sign = instr[31];
            exponent = 8'b11111111;
            fraction = 23'b0;
        end else if (nan) begin
            sign = instr[31];
            exponent = 8'b11111111;
            fraction = instr[22:0];
        end else begin
            sign = instr[31];
            exponent = instr[30:23];
            fraction = instr[22:0];
        end
    end

endmodule