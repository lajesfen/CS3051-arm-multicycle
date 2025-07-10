module hexdisplay(
    input clk,
    input reset,
    input[15:0] data,
    output wire[3:0] anode,
    output wire[7:0]catode
);
    wire scl_clk;
    wire[3:0] digit;
    
    clkdivider sc(
        .clk(clk),
        .reset(reset),
        .t(scl_clk)
    );

    hfsm m(
        .clk(scl_clk),
        .reset(reset),
        .data(data),
        .digit(digit),
        .anode(anode)
    );

    hexto7seg decoder (
        .digit(digit),
        .catode(catode)
    );
endmodule