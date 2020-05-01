`timescale 10ns / 1ns
module clock_divider(
    input clk,
    output reg divided_clk = 0,
	 output reg digit_clk = 0
    );

	integer counter_value = 0;
	integer counter_digit = 0;
	 
	 always@ (posedge clk)
		begin
			if(counter_value == 600000)
				counter_value <= 0;
			else
				counter_value <= counter_value + 1;
		end
		
	 always@ (posedge clk)
		begin
			if(counter_value == 600000)
				divided_clk <= ~divided_clk;
			else
				divided_clk <= divided_clk;
		end
		
	 always@ (posedge clk)
		begin
			if(counter_digit == 5000)
				counter_digit <= 0;
			else
				counter_digit <= counter_digit + 1;
		end
		
	 always@ (posedge clk)
		begin
			if(counter_digit == 5000)
				digit_clk <= ~digit_clk;
			else
				digit_clk <= digit_clk;
		end
		
endmodule
