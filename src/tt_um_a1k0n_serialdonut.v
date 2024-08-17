`default_nettype none

module tt_um_a1k0n_serialdonut(
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

wire tx_out;

defparam top.CLOCK_DIVIDER = 417;  // 115200 baud rate

top top(
  .clk(clk),
  .nrst(rst_n),
  .tx(tx_out)
);

assign uo_out  = {7'b0, tx_out};
assign uio_out = 8'b0;
assign uio_oe  = 8'b0;

wire _unused_ok = &{ui_in, uio_in, ena};

endmodule
