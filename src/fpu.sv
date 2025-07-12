module fpu(
    input [31:0] a, b,
    input FPUControl,
    output reg [31:0] Result
);
    wire [31:0] fpadd_res;
    wire [31:0] fpmul_res;

    fpadd fpuadd_inst (
        .a(a),
        .b(b),
        .Result(fpadd_res)
    );

    fpmul fpumul_inst (
        .a(a),
        .b(b),
        .Result(fpmul_res)
    );

    always @(*)
        begin
            casex (FPUControl)
                1'b0: Result = fpadd_res; // add
                1'b1: Result = fpmul_res; // mul
            endcase
        end

endmodule