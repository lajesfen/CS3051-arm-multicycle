module mul(
    input wire [31:0] a,
    input wire [31:0] b,
    output reg [63:0] result
);
    integer i;
    reg [63:0] multiplicand;
    reg [31:0] multiplier;
    reg [63:0] product;

    always @(*) begin
        multiplicand = {32'b0, a};
        multiplier = b;
        product = 64'b0;

        for (i = 0; i < 32; i = i + 1) begin
            if (multiplier[0] == 1'b1)
                product = product + multiplicand;

            multiplicand = multiplicand << 1;
            multiplier = multiplier >> 1;
        end

        result = product[0:31];
    end
endmodule