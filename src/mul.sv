module mul(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire signed,
    output reg [63:0] result
);
    integer i;
    reg [63:0] multiplicand;
    reg [31:0] multiplier;
    reg [63:0] product;

    always @(*) begin
        if (signed)
            multiplicand = {32{a[31]}, a};
        else
            multiplicand = {32'b0, a};
        
        multiplier = b;
        product = 64'b0;

        for (i = 0; i < 32; i = i + 1) begin
            if (multiplier[0] == 1'b1)
                product = product + multiplicand;

            multiplicand = multiplicand << 1;
            multiplier = multiplier >> 1;
        end

        result = product;
    end
endmodule