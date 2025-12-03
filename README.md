final_practice_top ~ top module 
final_practice ~ sub module
led_game_tb ~ testbench for top module

The project implements a memory based LED game on an FPGA using Verilog. The main module uses a finite state machine to control 16 LEDs, green indicators, and several 7 segment displays. Early rounds show fixed LED patterns, then wait for the player to reproduce the pattern through switch inputs within a countdown period. The display shows the round number and the system records the highest round reached. A Simon style round extends the game by flashing a stored sequence of LED positions, then checking player inputs against the sequence. The top module links all signals, while the testbench verifies timing, state transitions, LED patterns, and correct responses through simulated inputs.
