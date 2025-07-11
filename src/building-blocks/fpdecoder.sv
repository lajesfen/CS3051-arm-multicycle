module fpdecoder(
    input [31:0] instr,
    output reg sign,
    output reg [7:0] exponent,
    output reg [22:0] fraction
);
    wire [7:0] raw_exp = instr[30:23];
    wire [22:0] raw_frac = instr[22:0];

    wire is_zero = (raw_exp == 8'd0) && (raw_frac == 0);
    wire is_inf  = (raw_exp == 8'd255) && (raw_frac == 0);
    wire is_nan  = (raw_exp == 8'd255) && (raw_frac != 0);

    always @(*) begin
        sign = instr[31];

        if (is_zero) begin
            exponent = 8'd0;
            fraction = 23'd0;
        end else if (is_inf) begin
            exponent = 8'd255;
            fraction = 23'd0;
        end else if (is_nan) begin
            exponent = 8'd255;
            fraction = raw_frac;
        end else begin
            exponent = raw_exp;
            fraction = raw_frac;
        end
    end
endmodule