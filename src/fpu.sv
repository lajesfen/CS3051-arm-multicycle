module fpu(input [31:0] a, b,
           input FPUControl,
           output reg [31:0] Result);

    always @(*)
        begin
            casex (FPUControl)
                1'b0: Result = a + b; // add
                1'b1: Result = a * b; // mul
            endcase
        end

endmodule