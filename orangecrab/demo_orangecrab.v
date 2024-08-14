module demo_orangecrab (
    input clk48,
    input usr_btn,
    output gpio_0  // usart tx
);

defparam top.tx_inst.CLOCK_DIVIDER = 417;  // 115200 baud rate

top top(
  .clk(clk48),
  .nrst(usr_btn),
  .tx(gpio_0)
);

endmodule
