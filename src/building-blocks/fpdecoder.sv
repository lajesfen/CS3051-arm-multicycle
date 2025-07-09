module fpdecoder(
    input [31:0] instr,
    output wire sign,
    output wire [7:0] exponent,
    output wire [8:0] unbiexponent,
    output wire normalized,
    output wire [23:0] mantissa
);
    assign sign = instr[31];
    assign exponent = instr[30:23];
    assign unbiexponent = exponent - 8'd127;
    assign normalized = (exponent != 8'b0);
    assign mantissa = instr[22:0];

    // VER SI ES NECESARIO AGREGAR ESTO:
    // assign zero = (exponent == 8'd0) && (instr[22:0] == 23'd0);
    // assign inf = (exponent == 8'd255) && (instr[22:0] == 23'd0);
    // assign nan = (exponent == 8'd255) && (instr[22:0] != 23'd0);

    // assign FPFlags = {zero, inf, nan};
endmodule