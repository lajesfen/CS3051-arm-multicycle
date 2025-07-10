module hexto7seg (input[3:0] digit, output reg[7:0] catode);
    always @(*) begin
        case (digit)        //   _A_B_C_D_E_F_G_dp
            4'b0000: catode = 8'b_0_0_0_0_0_0_1_1; // 0
            4'b0001: catode = 8'b_1_0_0_1_1_1_1_1; // 1
            4'b0010: catode = 8'b_0_0_1_0_0_1_0_1; // 2
            4'b0011: catode = 8'b_0_0_0_0_1_1_0_1; // 3
            4'b0100: catode = 8'b_1_0_0_1_1_0_0_1; // 4
            4'b0101: catode = 8'b_0_1_0_0_1_0_0_1; // 5
            4'b0110: catode = 8'b_0_1_0_0_0_0_0_1; // 6
            4'b0111: catode = 8'b_0_0_0_1_1_1_1_1; // 7
            4'b1000: catode = 8'b_0_0_0_0_0_0_0_1; // 8
            4'b1001: catode = 8'b_0_0_0_0_1_0_0_1; // 9
            4'b1010: catode = 8'b_0_0_0_1_0_0_0_1; // A
            4'b1011: catode = 8'b_1_1_0_0_0_0_0_1; // B
            4'b1100: catode = 8'b_0_1_1_0_0_0_1_1; // C
            4'b1101: catode = 8'b_1_0_0_0_0_1_0_1; // D
            4'b1110: catode = 8'b_0_1_1_0_0_0_0_1; // E
            4'b1111: catode = 8'b_0_1_1_1_0_0_0_1; // F
            default: catode = 8'b_1_1_1_1_1_1_1_1;
        endcase
    end
endmodule