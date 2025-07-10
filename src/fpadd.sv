module fpadd(
    input [31:0] a, b,
    output reg [31:0] Result
);
    wire a_sign, b_sign;
    wire [7:0] a_exponent, b_exponent;
    wire [22:0] a_fraction, b_fraction;

    fpdecoder fpdec_a (
        .instr(a),
        .sign(a_sign),
        .exponent(a_exponent),
        .fraction(a_fraction)
    );

    fpdecoder fpdec_b (
        .instr(b),
        .sign(b_sign),
        .exponent(b_exponent),
        .fraction(b_fraction)
    );

    wire [23:0] a_mantissa = {1'b1, a_fraction}; // Add implicit leading 1
    wire [23:0] b_mantissa = {1'b1, b_fraction};

    wire [7:0] max_exponent = (a_exponent > b_exponent) ? a_exponent : b_exponent; // Check max exponent
    wire [7:0] exponent_diff = (a_exponent > b_exponent) ? (a_exponent - b_exponent) : (b_exponent - a_exponent);

    wire [23:0] aligned_a_mantissa = (a_exponent >= b_exponent) ? a_mantissa : (a_mantissa >> exponent_diff); // Shift smaller mantissa by exponent_diff
    wire [23:0] aligned_b_mantissa = (b_exponent >= a_exponent) ? b_mantissa : (b_mantissa >> exponent_diff);

    reg [24:0] operation_mantissa;
    reg result_sign;
    reg [7:0] result_exponent;
    reg [23:0] result_mantissa;
    integer shift_count;

    // ToDo: Handle rounding

    always @(*) begin
        if ((a[30:0] == 0) && (b[30:0] == 0)) begin // Check for zero inputs
            Result = 32'h00000000;
        end else begin
            if (a_sign == b_sign) begin // Same sign addition
                operation_mantissa = aligned_a_mantissa + aligned_b_mantissa;

                if (operation_mantissa[24]) begin // Overflow case
                    result_exponent = max_exponent + 1;
                    result_mantissa = operation_mantissa[24:1];
                end else begin
                    result_exponent = max_exponent;
                    result_mantissa = operation_mantissa[23:0];
                end

                result_sign = a_sign;
            end else begin // Different sign subtraction
                if (aligned_a_mantissa > aligned_b_mantissa) begin
                    operation_mantissa = aligned_a_mantissa - aligned_b_mantissa;
                    result_sign = a_sign;
                end else begin
                    operation_mantissa = aligned_b_mantissa - aligned_a_mantissa;
                    result_sign = b_sign;
                end

                shift_count = 0;
                while (operation_mantissa[23] == 0 && operation_mantissa != 0) begin
                    operation_mantissa = operation_mantissa << 1;
                    shift_count = shift_count + 1;
                end

                result_exponent = max_exponent - shift_count;
                result_mantissa = operation_mantissa[23:0];
            end

            Result = {result_sign, result_exponent, result_mantissa[22:0]}; // Remove implicit leading 1
        end
    end
endmodule
