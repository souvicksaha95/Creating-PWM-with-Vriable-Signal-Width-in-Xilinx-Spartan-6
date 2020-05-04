`timescale 10ns/1ns

module create_pwm(
	input clk,
	input button_up, button_down,
	output reg [0:6] segments,
	output reg [0:3] p1,
	output [3:0] led,
	output pwm_pin
	);
	
wire divided_clk, digit_clk; //one clock is for counting seconds, the second one is to drive the seven segment display.
wire [3:0] thousand, hundred, ten, one;
integer duty_cycle = 0, digit = 0;
reg [15:0] pulse_width; //pulse widh = 50 * duty_cycle, in microseconds.	
reg button_up_old = 0, button_up_raise = 0, button_down_old = 0, button_down_raise = 0;
localparam reach_value = 60000;  //12MHz divided by 60000 = 200, so in 1 sec, counter will reset 200 times, resulting time period = 5ms.
reg [15:0] counter;

clock_divider DUT(.clk(clk), .divided_clk(divided_clk), .digit_clk(digit_clk));
binary_to_bcd_big DUT_1(.clk(clk), .sixteen_bit_value(pulse_width), .ones(one), .tens(ten), .hundreds(hundred), .thousands(thousand));

always @(posedge clk)
	begin
		if(counter < reach_value)
			counter <= counter + 1;
		else
			counter <= 0;
	end
	
initial
	begin
		pulse_width = 16'h0000;
		p1 = 4'b1110;
	end
	
always @(posedge digit_clk)
	begin
		if (p1 != 4'b0111)
			p1 = (p1 << 1) | 4'b0001;
		else
			p1 = 4'b1110;
		case (p1)
			4'b1110 : 
				begin 
					digit = one[3:0];
				end
			4'b1101 : 
				begin
					digit = ten[3:0];
				end
			4'b1011 : 
				begin 
					digit = hundred[3:0];
				end
			4'b0111 : 
				begin
					digit = thousand[3:0];
				end
			endcase
	end
	
always @(digit)
	case (digit)
		0 : segments = 7'b0000001;
		1 : segments = 7'b1001111;
		2 : segments = 7'b0010010;
		3 : segments = 7'b0000110;
		4 : segments = 7'b1001100;
		5 : segments = 7'b0100100;
		6 : segments = 7'b0100000;
		7 : segments = 7'b0001111;
		8 : segments = 7'b0000000;
		9 : segments = 7'b0000100;
		4'ha : segments = 7'b0001000;
		4'hb : segments = 7'b0000000;
		4'hc : segments = 7'b0110001;
		4'hd : segments = 7'b0000001;
		4'he : segments = 7'b0110000;
		4'hf : segments = 7'b0111000;
	endcase
	
always @(posedge divided_clk)
	begin
		if (button_up_old != button_up && button_up == 1'b1)
          button_up_raise <= 1'b1;
		else if (button_down_old != button_down && button_down == 1'b1)
          button_down_raise <= 1'b1;
		button_up_old <= button_up;
		button_down_old <= button_down;
		if(button_up_raise == 1'b1)
			begin
				if(button_up)
					begin
						if (duty_cycle <= 99)
							duty_cycle <= duty_cycle + 1;
						else
							duty_cycle <= 0;
					end
			end
		if(button_down_raise == 1'b1)
			begin
				if(button_down)
					begin
						if (duty_cycle > 0)
							duty_cycle <= duty_cycle - 1;
					end
			end
		pulse_width = 50 * duty_cycle;
	end
	
assign led = (counter < (600 * duty_cycle))?4'b1111:4'b0000; //24000 is 40% of 5ms = 2ms will the on time.

assign pwm_pin = (counter < (600 * duty_cycle))?1:0;

endmodule
