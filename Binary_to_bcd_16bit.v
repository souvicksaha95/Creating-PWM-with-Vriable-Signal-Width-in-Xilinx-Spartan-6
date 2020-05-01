`timescale 10ns/1ns

module binary_to_bcd_big(
	input clk,
	input [15:0] sixteen_bit_value,
	output reg [3:0] ones = 0,
	output reg [3:0] tens = 0,
	output reg [3:0] hundreds = 0,
	output reg [3:0] thousands = 0
	);
	
reg [3:0] i = 0;
reg [23:0] shift_register = 0;
reg [3:0] temp_ones = 0;
reg [3:0] temp_tens = 0;
reg [3:0] temp_hunndreds = 0;
reg [3:0] temp_thousands = 0;
reg [15:0] old_sixteen_bit_value = 0;

always @(posedge clk)
	begin
		if((i==0) & (old_sixteen_bit_value != sixteen_bit_value))
			begin
				shift_register = 24'd0;
				old_sixteen_bit_value = sixteen_bit_value;
				shift_register[15:0] = sixteen_bit_value;
				temp_thousands = shift_register[23:20];
				temp_hunndreds = shift_register[19:16];
				temp_tens = shift_register[15:12];
				temp_ones = shift_register[11:8];
				i = i + 1;
			end
		if(i < 9 & i > 0)
			begin
				if(temp_thousands >= 5) temp_thousands = temp_thousands + 3;
				if(temp_hunndreds >= 5) temp_hunndreds = temp_hunndreds + 3;
				if(temp_tens >= 5) temp_tens = temp_tens + 3;
				if(temp_ones >= 5) temp_ones = temp_ones + 3;
				shift_register[19:8] = {temp_thousands, temp_hunndreds, temp_tens, temp_ones};
				shift_register	= shift_register << 1;
				temp_thousands = shift_register[23:20];
				temp_hunndreds = shift_register[19:16];
				temp_tens = shift_register[15:12];
				temp_ones = shift_register[11:8];
				i = i + 1;
			end
		if(i == 9)
			begin
				i = 0;
				thousands = temp_thousands;
				hundreds = temp_hunndreds;
				tens = temp_tens;
				ones = temp_ones;
			end
	end
endmodule
