module clkdivider(input clk, input reset, output reg t);
    reg [16:0] counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            t <= 0;
        end else begin
            if (counter == 999999) begin
                counter <= 0;
                t <= ~t;
            end else begin
                counter <= counter + 1;
            end
        end
    end
endmodule