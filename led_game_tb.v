
`timescale 1ns/1ps

module led_game_tb;

  reg clk;
  reg rst;
  reg [15:0] sw;
  reg [3:0] key;
  wire [15:0] led;
  wire [7:0] ledg;
  wire [6:0] hex0, hex1, hex4, hex6;

  // Instantiate the module
  led_game uut (
    .clk(clk),
    .rst(rst),
    .sw(sw),
    .key(key),
    .led(led),
    .ledg(ledg),
    .hex0(hex0),
    .hex1(hex1),
    .hex4(hex4),
    .hex6(hex6)
  );

  // Clock generation
  always #10 clk = ~clk;

  initial begin
    $dumpfile("led_game_tb.vcd");
    $dumpvars(0, led_game_tb);

    // Initialize inputs
    clk = 0;
    rst = 0;
    sw = 16'b0;
    key = 4'b1111;

    // Apply reset
    #100;
    rst = 1;
    #100;
    rst = 0;

    // Simulate pressing key[1] for ROUND 2
    #200;
    key[1] = 0;
    #50;
    key[1] = 1;

    // Simulate correct switch inputs for ROUND 2
    #500;
    sw = 16'b0000000010110010; // matching FLASH_2
    #300;
    sw = 0;

    // Simulate pressing key[2] for ROUND 3
    #200;
    key[2] = 0;
    #50;
    key[2] = 1;

    // Simulate correct switch inputs for ROUND 3
    #500;
    sw = 16'b0010000100101010; // matching FLASH_3
    #300;
    sw = 0;

    // Simulate pressing key[3] for SIMON ROUND
    #200;
    key[3] = 0;
    #50;
    key[3] = 1;

    // Simulate Simon input sequence
    #1000;
    sw = 1 << 2; #100; sw = 0;
    sw = 1 << 10; #100; sw = 0;
    sw = 1 << 5; #100; sw = 0;
    sw = 1 << 13; #100; sw = 0;

    #2_000_000;
    $finish;
  end

endmodule
