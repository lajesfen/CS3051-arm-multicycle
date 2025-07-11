module fpdecoder16(
    input [15:0] instr,
    output reg sign,
    output reg [4:0] exponent,
    output reg [9:0] fraction
);
    wire [4:0] raw_exp = instr[14:10];
    wire [9:0] raw_frac = instr[9:0];

    wire is_zero = (raw_exp == 5'd0) && (raw_frac == 0);
    wire is_inf  = (raw_exp == 5'd31) && (raw_frac == 0);
    wire is_nan  = (raw_exp == 5'd31) && (raw_frac != 0);

    always @(*) begin
        sign = instr[15];

        if (is_zero) begin
            exponent = 5'd0;
            fraction = 10'd0;
        end else if (is_inf) begin
            exponent = 5'd31;
            fraction = 10'd0;
        end else if (is_nan) begin
            exponent = 5'd31;
            fraction = raw_frac;
        end else begin
            exponent = raw_exp;
            fraction = raw_frac;
        end
    end
endmodule
