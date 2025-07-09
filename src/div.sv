module div(
    input wire [31:0] a,  // dividendo
    input wire [31:0] b,  // divisor
    output reg [32:0] rem,// residuo
    output reg [31:0] q   // cociente
);
    integer i;
    reg [31:0] divisor;
    reg [31:0] quotent;
    reg [32:0] accumulator; // A = 00..0, size+1
    reg [64:0] temp;

    always @(*) begin
        divisor = {1'b0,b};
        quotent = a;
        accumulator = {33'b0};
        for (i = 0; i < 32; i = i + 1) begin
            temp = {accumulator, quotent};
            temp = temp << 1;
            
            accumulator = {temp[64:32]};
            accumulator = accumulator + ~divisor + 1; // A = A - B = A + ~B + 1
            
            // si es negativo
            if (accumulator[32] == 1) begin
                quotent = {temp[31:1], 1'b0};
                accumulator = accumulator + divisor; // restaurar
            end
            else 
              quotent = {temp[31:1], 1'b1};
        end
        
        // asignar residuo y cociente
        rem = accumulator;
        q = quotent;
    end    
endmodule