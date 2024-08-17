`default_nettype none

module vectoring_cordic (
  input clk,
  input start,
  input signed [15:0] xin,
  input signed [15:0] yin,
  input signed [15:0] x2in,
  input signed [15:0] y2in,
  output signed [15:0] xout,
  output signed [15:0] x2out,
  output wire done
);

reg [2:0] cycle;

// done means the next clock cycle the result will be finalized, so you can load
// in a new value on the next clock
assign done = (cycle == 7);

reg signed [15:0] x, y;
reg signed [15:0] x2, y2;

assign xout = (x >>> 1) + (x >>> 3);
assign x2out = (x2 >>> 1) + (x2 >>> 3);

// we could make this whole thing serial one bit at a time to save a lot of die
// space...
always @(posedge clk) begin
  if (start) begin
    cycle <= 0;
    x <= xin;
    y <= yin;
    x2 <= x2in;
    y2 <= y2in;
  end else begin
    cycle <= cycle + 1;
    if (y[15]) begin
      x <= x - (y >>> cycle);
      y <= y + (x >>> cycle);
      x2 <= x2 - (y2 >>> cycle);
      y2 <= y2 + (x2 >>> cycle);
    end else begin
      x <= x + (y >>> cycle);
      y <= y - (x >>> cycle);
      x2 <= x2 + (y2 >>> cycle);
      y2 <= y2 - (x2 >>> cycle);
    end
  end
end

endmodule
