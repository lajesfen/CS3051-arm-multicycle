module mem (
	clk,
	we,
	a,
	wd,
	rd
);
	input wire clk;
	input wire we;
	input wire [31:0] a;
	input wire [31:0] wd;
	output wire [31:0] rd;
	reg [31:0] RAM [63:0];
	
	initial begin
		RAM[0] = 32'hE3A00000;
		RAM[1] = 32'hE2801005; 
		RAM[2] = 32'hE0212001; 
		RAM[3] = 32'hE1213401; 
		RAM[4] = 32'hE2406002; 
		RAM[5] = 32'hE1463401; 
		RAM[6] = 32'hE1463406; 
		RAM[7] = 32'hE1017001; 
		RAM[8] = 32'hE2406001;  
		RAM[9] = 32'hE1263406; 
		RAM[10] = 32'hE3A000CD;
		RAM[11] = 32'hE3A01B33;
		RAM[12] = 32'hE3A02703; 
		RAM[13] = 32'hE3A03101; 
		RAM[14] = 32'hE1800001; 
		RAM[15] = 32'hE1800002;
		RAM[16] = 32'hE1800003;
		RAM[17] = 32'hE1A01000; 
		RAM[18] = 32'hE1C12000;
	end
	
	assign rd = RAM[a[31:2]]; // word aligned read
	
	// Write to RAM on clock edge
	always @(posedge clk) begin
		if (we) begin
			RAM[a[31:2]] <= wd;
		end
	end
endmodule