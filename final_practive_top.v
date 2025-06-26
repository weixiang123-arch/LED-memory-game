module top (
    input wire clk,         // Clock input (assumed 50 MHz)
    input wire rst,         // Reset input (active high)
    input wire [15:0] sw,   // 16 switches input
    input wire [3:0] key,        // Submit button input
    output wire [15:0] led, // 16 LEDs output (main game LEDs)
    output wire [7:0] ledg, // 7 green LED output for correct answer
    output wire [6:0] hex0,  // 7-segment display HEX0 (units)
	 output wire [6:0] hex1,
	 output wire [6:0] hex4,
	 output wire [6:0] hex6
	 
);

    // Instantiate the led_game module and connect hex0 properly
    led_game game (
        .clk(clk),
        .rst(rst),
        .sw(sw),
        .led(led),
        .ledg(ledg),
        .hex0(hex0),   
		  .hex1(hex1),
		  .hex4(hex4),
		  .hex6(hex6),
		  .key(key)
    );

endmodule
