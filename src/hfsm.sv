module hfsm(
    input clk,
    input reset,
    input[15:0] data,
    output reg[3:0] digit,
    output reg[3:0] anode
);
    reg [1:0] state, nextstate;

    parameter D0 = 2'b00;
    parameter D1 = 2'b01;
    parameter D2 = 2'b10;
    parameter D3 = 2'b11;

    always @(posedge clk, posedge reset) begin
        if (reset) state <= D0;
  	    else state <= nextstate;
    end

    always @(*) begin
        case (state)
            D0: begin
                digit <= data[15:12];
                anode <= 4'b0111;
                nextstate = D1;
            end
            D1: begin 
                digit <= data[11:8];
                anode <= 4'b1011;
                nextstate = D2;
            end
            D2: begin
                digit <= data[7:4];
                anode <= 4'b1101;
                nextstate = D3;
            end
            D3: begin
                digit <= data[3:0];
                anode <= 4'b1110;
                nextstate = D0;
            end
            default: nextstate = D0;
        endcase
    end  

endmodule