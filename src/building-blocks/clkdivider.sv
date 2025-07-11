module clkdivider #(parameter DIVIDE_BY = 2)(input clk, input reset, output reg t);
    localparam WIDTH = $clog2(DIVIDE_BY);
    reg [WIDTH-1:0] counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            t <= 0;
        end else begin
            if (counter == (DIVIDE_BY/2 - 1)) begin
                t <= ~t;
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end
endmodule