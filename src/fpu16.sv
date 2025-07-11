module fpu16(
    input [31:0] a, b,
    input FPUControl,
    output reg [31:0] Result
);
    wire [15:0] fpadd_res;
    wire [15:0] fpmul_res;

    fpadd16 fpuadd_inst (
        .a(a[15:0]),
        .b(b[15:0]),
        .Result(fpadd_res)
    );

    // ToDo: Add fpmul module

    always @(*)
        begin
            casex (FPUControl)
                1'b0: Result = {16'b0, fpadd_res}; // add
                1'b1: Result = {16'b0, fpmul_res}; // mul
            endcase
        end

endmodule