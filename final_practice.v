module led_game (
    input clk,
    input rst,
    input [15:0] sw,
	 input [3:0] key,
    output reg [15:0] led,
    output reg [7:0] ledg,
    output reg [6:0] hex0,
    output reg [6:0] hex1,
    output reg [6:0] hex4,
    output reg [6:0] hex6
);

    localparam WAIT = 0, 
        FLASH_1 = 1, CHECK_1 = 2, RESPONSE_WAIT_1 = 3,
        FLASH_2 = 4, CHECK_2 = 5, RESPONSE_WAIT_2 = 6,
        FLASH_3 = 7, CHECK_3 = 8, RESPONSE_WAIT_3 = 9,
        FLASH_4 = 10, CHECK_4 = 11, RESPONSE_WAIT_4 = 12,
		  SIMON_INIT = 13, SIMON_FLASH = 14, SIMON_WAIT_INPUT = 15,
		  SIMON_INIT_2 = 16, SIMON_FLASH_2 = 17, SIMON_WAIT_INPUT_2 = 18;


    reg [3:0] state = WAIT;
    reg [25:0] timer = 0;
    reg [3:0] response_timer = 0;

    reg [3:0] current_round = 0;
    reg [3:0] high_score = 1;
	 
	 reg [3:0] simon_sequence[0:3]; // Stores the LED positions (0-15)
	 reg [1:0] simon_index;         // Index for current LED in sequence
	 reg [3:0] simon_flash_timer;   // Delay between LED flashes
	 reg [1:0] simon_input_index;   // Index for checking player's input

    reg [24:0] slow_clk_divider = 0;
    wire slow_clk;

    always @(posedge clk)
        slow_clk_divider <= slow_clk_divider + 1;
    assign slow_clk = slow_clk_divider[24];

    function [6:0] hex_to_7seg;
        input [3:0] hex;
        begin
            case (hex)
                4'h0: hex_to_7seg = 7'b1000000;
                4'h1: hex_to_7seg = 7'b1111001;
                4'h2: hex_to_7seg = 7'b0100100;
                4'h3: hex_to_7seg = 7'b0110000;
                4'h4: hex_to_7seg = 7'b0011001;
                4'h5: hex_to_7seg = 7'b0010010;
                4'h6: hex_to_7seg = 7'b0000010;
                4'h7: hex_to_7seg = 7'b1111000;
                4'h8: hex_to_7seg = 7'b0000000;
                4'h9: hex_to_7seg = 7'b0010000;
                default: hex_to_7seg = 7'b1111111;
            endcase
        end
    endfunction
	 

    always @(posedge slow_clk) begin
        if (~rst) begin
            state <= WAIT;
            timer <= 0;
            response_timer <= 0;
            led <= 16'hFFFF;
            ledg <= 8'hFF;
            hex0 <= 7'b1111111;
            hex1 <= 7'b1111111;
            hex4 <= 7'b1111111;
            // Do NOT reset high_score
            current_round <= 0;
				simon_index <= 0;
				simon_input_index <= 0;
				simon_flash_timer <= 0;
        end
		  if (~key[1]) begin
		       hex0 <= 7'b1111111;
             hex1 <= 7'b1111111;
				 state <= FLASH_2;
				 current_round <= 2;
				 timer <= 0;
				 led <= 0;
				 hex4 <= hex_to_7seg(2);	 
		  end 
		  if (~key[2]) begin
				 hex0 <= 7'b1111111;
             hex1 <= 7'b1111111;
				 state <= FLASH_3;
				 current_round <= 3;
				 timer <= 0;
				 led <= 0;
				
				 hex4 <= hex_to_7seg(3);
				end
			if (~key[3]) begin
				 hex0 <= 7'b1111111;
             hex1 <= 7'b1111111;
				 state <= SIMON_INIT;
				 current_round <= 4;
				 timer <= 0;
				 led <= 0;
				 hex4 <= hex_to_7seg(4); 
				end
		  
		 
		  else begin
            ledg <= 8'h00;

            case (state)
                WAIT: begin
                    led <= 16'hFFFF;
                    timer <= timer + 1;
                    hex0 <= 7'b1111111;
                    hex1 <= 7'b1111111;
                    hex4 <= hex_to_7seg(0);
                    if (timer > 3) begin
                        state <= FLASH_1;
                        current_round <= 1;
                        hex4 <= hex_to_7seg(1);
                        timer <= 0;
                        led <= 0;
                    end
                end

					 FLASH_1: begin
							 if (|sw) begin
								  led <= 16'hFFFF;
							 end else begin
								  led <= 16'b0000000001000100;
							 end

							 timer <= timer + 1;
							 if (timer >= 3) begin
								  state <= CHECK_1;
								  timer <= 0;
							 end
						end
                CHECK_1: begin
                    led <= 0;
                    state <= RESPONSE_WAIT_1;
                    response_timer <= 0;
                end
                RESPONSE_WAIT_1: begin
                    response_timer <= response_timer + 1;
                    if (response_timer <= 8) begin
                        hex1 <= hex_to_7seg((8 - response_timer) / 10);
                        hex0 <= hex_to_7seg((8 - response_timer) % 10);
                    end else begin
                        hex0 <= 7'b1111111;
                        hex1 <= 7'b1111111;
                    end

                    if (sw[2] && sw[6] && !sw[0] && !sw[1]) begin
                        ledg <= 8'hFF;
                        state <= FLASH_2;
                        current_round <= 2;
                        if (high_score < 2) high_score <= 2;
                        hex4 <= hex_to_7seg(2);
                        hex6 <= hex_to_7seg(high_score < 2 ? 2 : high_score);
                        response_timer <= 0;
                        hex0 <= 7'b1111111;
                        hex1 <= 7'b1111111;
                    end else if (response_timer >= 9) begin
                        ledg[6] <= 1;
                        state <= WAIT;
                        timer <= 0;
                        hex0 <= 7'b1111111;
                        hex1 <= 7'b1111111;
                    end
                end

                FLASH_2: begin
							 if (|sw) begin
								  led <= 16'hFFFF;
							 end else
                    led <= 16'b0000000010110010;
                    timer <= timer + 1;
                    if (timer >= 3) begin
                        state <= CHECK_2;
                        timer <= 0;
                    end
                end
                CHECK_2: begin
                    led <= 0;
                    state <= RESPONSE_WAIT_2;
                    response_timer <= 0;
                end
                RESPONSE_WAIT_2: begin
                    response_timer <= response_timer + 1;
                    if (response_timer <= 10) begin
                        hex1 <= hex_to_7seg((10 - response_timer) / 10);
                        hex0 <= hex_to_7seg((10 - response_timer) % 10);
                    end else begin
                        hex0 <= 7'b1111111;
                        hex1 <= 7'b1111111;
                    end

                    if (sw[1] && sw[4] && sw[5] && sw[7] && !sw[2] && !sw[6]) begin
                        ledg <= 8'hFF;
                        state <= FLASH_3;
                        current_round <= 3;
                        if (high_score < 3) high_score <= 3;
                        hex4 <= hex_to_7seg(3);
                        hex6 <= hex_to_7seg(high_score < 3 ? 3 : high_score);
                        response_timer <= 0;
                        hex0 <= 7'b1111111;
                        hex1 <= 7'b1111111;
                    end else if (response_timer >= 11) begin
                        ledg[6] <= 1;
                        state <= WAIT;
                        timer <= 0;
                        hex0 <= 7'b1111111;
                        hex1 <= 7'b1111111;
                    end
                end

                FLASH_3: begin
							 if (|sw) begin
								  led <= 16'hFFFF;
							 end else
                    led <= 16'b0010000100101010;
                    timer <= timer + 1;
                    if (timer >= 3) begin
                        state <= CHECK_3;
                        timer <= 0;
                    end
                end
                CHECK_3: begin
                    led <= 0;
                    state <= RESPONSE_WAIT_3;
                    response_timer <= 0;
                end
                RESPONSE_WAIT_3: begin
                    response_timer <= response_timer + 1;
                    if (response_timer <= 12) begin
                        hex1 <= hex_to_7seg((12 - response_timer) / 10);
                        hex0 <= hex_to_7seg((12 - response_timer) % 10);
                    end else begin
                        hex0 <= 7'b1111111;
                        hex1 <= 7'b1111111;
                    end

                    if (sw[1] && sw[3] && sw[5] && sw[8] && sw[13] && !sw[4] && !sw[7]) begin
                        ledg <= 8'hFF;
                        state <= SIMON_INIT;
                        current_round <= 4;
                        if (high_score < 4) high_score <= 4;
                        hex4 <= hex_to_7seg(4);
                        hex6 <= hex_to_7seg(high_score < 4 ? 4 : high_score);
                        response_timer <= 0;
                        hex0 <= 7'b1111111;
                        hex1 <= 7'b1111111;
                    end else if (response_timer >= 13) begin
                        ledg[6] <= 1;
                        state <= WAIT;
                        timer <= 0;
                        hex0 <= 7'b1111111;
                        hex1 <= 7'b1111111;
                    end
                end
					 
					  SIMON_INIT: begin
								// Hardcoded sequence: LED positions (bit indexes)
								simon_sequence[0] <= 2;
								simon_sequence[1] <= 10;
								simon_sequence[2] <= 5;
								simon_sequence[3] <= 13;
    
								simon_index <= 0;
								simon_flash_timer <= 0;
								state <= SIMON_FLASH;
								response_timer <= 0;
					 end
					 
					 SIMON_FLASH: begin
							if (simon_flash_timer == 0) begin
									led <= 1 << simon_sequence[simon_index];  // Light current LED
									simon_flash_timer <= simon_flash_timer + 1;
							end else if (simon_flash_timer < 2) begin
									simon_flash_timer <= simon_flash_timer + 1; // Hold LED on
							end else begin
									led <= 0; // Turn off LED
									simon_flash_timer <= 0;
									simon_index <= simon_index + 1;
        
							if (simon_index == 3) begin
									simon_input_index <= 0;
									state <= SIMON_WAIT_INPUT;
							end
						end
					 end
					 
					 SIMON_WAIT_INPUT: begin
							  response_timer <= response_timer + 1;
                    if (response_timer <= 14) begin
                        hex1 <= hex_to_7seg((14 - response_timer) / 10);
                        hex0 <= hex_to_7seg((14 - response_timer) % 10);
                    end else begin
                        hex0 <= 7'b1111111;
                        hex1 <= 7'b1111111;
                    end


							 if (sw[simon_sequence[simon_input_index]]) begin
								  simon_input_index <= simon_input_index + 1;
								  // Do NOT reset response_timer here

								  if (simon_input_index == 3) begin
										ledg <= 8'hFF;
										state <= WAIT;  
										timer <= 0;
										current_round <= 5;

										hex0 <= 7'b1111111;
										hex1 <= 7'b1111111;
										  end
									 end

							 // Timeout: fail
							 if (response_timer >= 15) begin
								  ledg[6] <= 1;
								  simon_input_index <= 0;
								  response_timer <= 0;
								  state <= SIMON_INIT;
								  hex0 <= 7'b1111111;
								  hex1 <= 7'b1111111;
							 end
						end
						
					
            endcase
				
				hex6 <= hex_to_7seg(high_score);

        end
    end
endmodule
