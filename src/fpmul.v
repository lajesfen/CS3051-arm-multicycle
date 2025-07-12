module fpmul(
    input  [31:0] a, b,
    output reg [31:0] Result
);

    wire a_sign, b_sign;
    wire [7:0] a_exp, b_exp;
    wire [23:0] a_frac, b_frac;

    fpdecoder fpdec_a (
        .instr(a),
        .sign(a_sign),
        .exponent(a_exp),
        .fraction(a_frac)
    );
    
    fpdecoder fpdec_b (
        .instr(b),
        .sign(b_sign),
        .exponent(b_exp),
        .fraction(b_frac)
    );

    // 1. detección de valores especiales según la tabla IEEE 754
    // - NaN: exponente todo 1s y mantisa distinta de cero
    // - inf: exponente todo 1s y mantisa igual a cero
    // - 0: exponente y mantisa todo ceros
    wire a_is_nan  = (a_exp == 8'hFF) && (a_frac[22:0] != 0);
    wire b_is_nan  = (b_exp == 8'hFF) && (b_frac[22:0] != 0);
    wire a_is_inf  = (a_exp == 8'hFF) && (a_frac[22:0] == 0);
    wire b_is_inf  = (b_exp == 8'hFF) && (b_frac[22:0] == 0);
    wire a_is_zero = (a_exp == 0) && (a_frac[22:0] == 0);
    wire b_is_zero = (b_exp == 0) && (b_frac[22:0] == 0);

    // 2. calcular el signo del resultado (XOR)
    wire result_sign = a_sign ^ b_sign;

    // 3. multiplicar las mantisas (fracciones)
    wire [47:0] prod = a_frac * b_frac;

    // 4. sumar exponentes y ajustar el bias (127)
    wire [9:0] exp_sum_raw = a_exp + b_exp - 8'd127;

     // 5. normalización y obtención de guard, round, sticky bits
    reg [22:0] mantissa_norm;
    reg [7:0] exponent_norm;
    reg guard, round, sticky;
    reg [22:0] mantissa_rounded;
    reg [7:0] exponent_rounded;
    
    always @(*) begin
        // 6. manejo de casos especiales (NaN, inf, cero)
        // NaN: Si alguno de los operandos es NaN
        if (a_is_nan || b_is_nan) begin
            Result = {1'b0, 8'hFF, 1'b1, 22'b0}; // QNaN
        // 0 * inf = NaN
        end else if ((a_is_zero && b_is_inf) || (a_is_inf && b_is_zero)) begin
            Result = {1'b0, 8'hFF, 1'b1, 22'b0};
        end else if (a_is_inf || b_is_inf) begin
            Result = {result_sign, 8'hFF, 23'b0}; // +Inf, -Inf
        end else if (a_is_zero || b_is_zero) begin
            Result = {result_sign, 8'b0, 23'b0}; // +0, -0
        end else begin
            // 8. normalización
            if (prod[47]) begin
                // si el bit más alto es 1, la mantisa está normalizada
                mantissa_norm = prod[46:24];
                guard  = prod[23];
                round  = prod[22];
                sticky = |prod[21:0]; // OR de todos los bits inferiores
                exponent_norm = exp_sum_raw[7:0] + 1; // ajuste del exponente
            end else begin
                mantissa_norm = prod[45:23];
                guard  = prod[22];
                round  = prod[21];
                sticky = |prod[20:0];
                exponent_norm = exp_sum_raw[7:0];
            end

            // redondeo
            // floating point rounding implementation
            if (guard && (round || sticky || mantissa_norm[0]))
                mantissa_rounded = mantissa_norm + 1'b1;
            else
                mantissa_rounded = mantissa_norm;

            // ajuste si hubo overflow al redondear
            if (mantissa_rounded == 24'h1000000) begin
                mantissa_rounded = 23'b0;
                exponent_rounded = exponent_norm + 1;
            end else begin
                exponent_rounded = exponent_norm;
            end

            // overflow (mayor o igual a 255)
            if (exponent_rounded >= 8'hFF) begin
                Result = {result_sign, 8'hFF, 23'b0}; // Inf
            end
            // underflow (exponente igual a 0)
            else if (exponent_rounded == 0) begin
                Result = {result_sign, 8'b0, mantissa_rounded};
            end
            else begin
                Result = {result_sign, exponent_rounded, mantissa_rounded};
            end
        end
    end

endmodule