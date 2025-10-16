`timescale 1 us/ 1 us
restart 
force reset_reset_n 0 
force reset_reset_n 1 100ns 
force clk_clk 1 0ns, 0 10ns -r 20ns
run 6000ms
