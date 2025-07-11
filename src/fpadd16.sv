module fpadd16(
    input [15:0] a, b,
    output reg [15:0] Result
);
    wire a_sign, b_sign;
    wire [4:0] a_exp, b_exp;
    wire [9:0] a_frac, b_frac;

    fpdecoder16 fpdec_a (
        .instr(a),
        .sign(a_sign),
        .exponent(a_exp),
        .fraction(a_frac)
    );

    fpdecoder16 fpdec_b (
        .instr(b),
        .sign(b_sign),
        .exponent(b_exp),
        .fraction(b_frac)
    );

    wire [10:0] a_mant = (a_exp != 0) ? {1'b1, a_frac} : {1'b0, a_frac};
    wire [10:0] b_mant = (b_exp != 0) ? {1'b1, b_frac} : {1'b0, b_frac};

    wire [4:0] exp_diff = (a_exp > b_exp) ? (a_exp - b_exp) : (b_exp - a_exp);
    wire [4:0] max_exp = (a_exp > b_exp) ? a_exp : b_exp;

    wire [10:0] a_aligned = (a_exp >= b_exp) ? a_mant : (a_mant >> exp_diff);
    wire [10:0] b_aligned = (b_exp >= a_exp) ? b_mant : (b_mant >> exp_diff);

    reg [11:0] mant_result;
    reg [4:0] result_exp;
    reg [10:0] norm_mant;
    reg result_sign;
    integer shift_count;

    always @(*) begin
        if ((a[14:0] == 0) && (b[14:0] == 0)) begin // Check for zero inputs
            Result = 16'h0000;
        end else begin
            if (a_sign == b_sign) begin // Same sign -> addition
                mant_result = a_aligned + b_aligned;

                if (mant_result[11]) begin // Overflow case
                    norm_mant = mant_result[11:1];
                    result_exp = max_exp + 1;
                end else begin
                    norm_mant = mant_result[10:0];
                    result_exp = max_exp;
                end

                result_sign = a_sign;
            end else begin // Different sign -> subtraction
                if (a_aligned > b_aligned) begin
                    mant_result = a_aligned - b_aligned;
                    result_sign = a_sign;
                end else begin
                    mant_result = b_aligned - a_aligned;
                    result_sign = b_sign;
                end

                shift_count = 0;
                while (mant_result[10] == 0 && mant_result != 0 && shift_count < 11) begin
                    mant_result = mant_result << 1;
                    shift_count = shift_count + 1;
                end

                norm_mant = mant_result[10:0];
                result_exp = max_exp - shift_count;
            end

            Result = {result_sign, result_exp, norm_mant[9:0]}; // Remove implicit leading 1
        end
    end
endmodule
