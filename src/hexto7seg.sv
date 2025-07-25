module hexto7seg (input[3:0] digit, output reg[7:0] catode);
    always @(*) begin
        case (digit)        //   ABCDEFGdp
            4'b0000: catode = 8'b00000011; // 0
            4'b0001: catode = 8'b10011111; // 1
            4'b0010: catode = 8'b00100101; // 2
            4'b0011: catode = 8'b00001101; // 3
            4'b0100: catode = 8'b10011001; // 4
            4'b0101: catode = 8'b01001001; // 5
            4'b0110: catode = 8'b01000001; // 6
            4'b0111: catode = 8'b00011111; // 7
            4'b1000: catode = 8'b00000001; // 8
            4'b1001: catode = 8'b00001001; // 9
            4'b1010: catode = 8'b00010001; // A
            4'b1011: catode = 8'b11000001; // B
            4'b1100: catode = 8'b01100011; // C
            4'b1101: catode = 8'b10000101; // D
            4'b1110: catode = 8'b01100001; // E
            4'b1111: catode = 8'b01110001; // F
            default: catode = 8'b11111111;
        endcase
    end
endmodule