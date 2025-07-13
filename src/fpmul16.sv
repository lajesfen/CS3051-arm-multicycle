module fpmul16(
    input  [15:0] a, b,
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

    wire a_is_nan  = (a_exp == 5'h1F) && (a_frac != 0);
    wire b_is_nan  = (b_exp == 5'h1F) && (b_frac != 0);
    wire a_is_inf  = (a_exp == 5'h1F) && (a_frac == 0);
    wire b_is_inf  = (b_exp == 5'h1F) && (b_frac == 0);
    wire a_is_zero = (a_exp == 0) && (a_frac == 0);
    wire b_is_zero = (b_exp == 0) && (b_frac == 0);

    reg result_sign;
    reg [11:0] a_mant, b_mant; 
    reg [23:0] mant_prod;
    reg [6:0] exp_sum, fexp, adjusted_exponent;
    reg [9:0] norm_mant, final_mantissa;
    reg overflow, underflow;
    reg guard, round, sticky, round_up;
    reg [10:0] rounded_mant;

    always @(*) begin
        if (a_is_nan || b_is_nan) begin
            Result = {1'b0, 5'h1F, 10'h200}; // NaN
        end else if ((a_is_zero && b_is_inf) || (a_is_inf && b_is_zero)) begin
            Result = {1'b0, 5'h1F, 10'h200}; // 0 * inf = NaN
        end else if (a_is_zero || b_is_zero) begin
            Result = {a_sign ^ b_sign, 5'd0, 10'd0}; // cero
        end else if (a_is_inf || b_is_inf) begin
            Result = {a_sign ^ b_sign, 5'h1F, 10'd0}; // infinito
        end else begin
            // signo del resultado final
            result_sign = a_sign ^ b_sign;

            // 1: normalizado, 0: denormalizado
            if (a_exp != 0)
                a_mant = {1'b1, a_frac, 1'b0}; 
            else
                a_mant = {1'b0, a_frac, 1'b0};
                
            if (b_exp != 0)
                b_mant = {1'b1, b_frac, 1'b0}; 
            else
                b_mant = {1'b0, b_frac, 1'b0}; 

            // producto mantisas y suma exponentes
            mant_prod = a_mant * b_mant;
            exp_sum = {2'b0, a_exp} + {2'b0, b_exp} - 7'd15; // bias para 16 bits: 15

            // normalización 
            if (mant_prod[23]) begin
                norm_mant = mant_prod[22:13];
                fexp = exp_sum + 1;
                guard = mant_prod[13];
                round = mant_prod[12];
                sticky = |mant_prod[11:0];
            end else begin
                norm_mant = mant_prod[21:12];
                fexp = exp_sum;
                guard = mant_prod[12];
                round = mant_prod[11];
                sticky = |mant_prod[10:0];
            end

            // overflow/underflow
            overflow = (fexp >= 7'd31);
            underflow = (fexp <= 7'd0);

            // redondeo
            round_up = round & (sticky | guard);
            rounded_mant = {1'b0, norm_mant} + round_up;

            if (rounded_mant[10]) begin
                adjusted_exponent = fexp + 1;
                final_mantissa = rounded_mant[9:0];
            end else begin
                adjusted_exponent = fexp;
                final_mantissa = rounded_mant[9:0];
            end

            if (overflow || (adjusted_exponent >= 7'd31)) begin
                Result = {result_sign, 5'h1F, 10'd0}; // overflow: infinito
            end else if (underflow || (adjusted_exponent <= 7'd0)) begin
                Result = {result_sign, 5'd0, 10'd0}; // underflow: cero
            end else begin
                Result = {result_sign, adjusted_exponent[4:0], final_mantissa};
            end
        end
    end

endmodule