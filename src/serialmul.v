`default_nettype none

module serialmul (
  input clk,
  input start,
  input signed [15:0] xin,
  input signed [15:0] yin,
  input signed [15:0] zin,
  input [10:0] d,
  output reg signed [15:0] xout,
  output reg signed [15:0] yout,
  output reg signed [15:0] zout,
  output wire done
);

reg signed [15:0] xshifted, yshifted, zshifted;
reg [10:0] dshifted;

// done means the next clock cycle the result will be finalized, so you can load
// in a new value
assign done = dshifted[9:0] == 0;

always @(posedge clk) begin
  if (start) begin
    xout <= 0;
    yout <= 0;
    zout <= 0;
    xshifted <= xin;
    yshifted <= yin;
    zshifted <= zin;
    dshifted <= d;
  end else begin
    if (dshifted[10]) begin
      xout <= xout + xshifted;
      yout <= yout + yshifted;
      zout <= zout + zshifted;
    end else begin
      xout <= xout;
      yout <= yout;
      zout <= zout;
    end
    dshifted <= dshifted << 1;
    xshifted <= xshifted >>> 1;
    yshifted <= yshifted >>> 1;
    zshifted <= zshifted >>> 1;
  end
end

endmodule
