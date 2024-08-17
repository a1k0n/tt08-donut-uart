#include <stdint.h>
#include "Vserialmul.h"
#include "Vserialmul__Syms.h"

int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv);

  Vserialmul *top = new Vserialmul;

  const int x = 28580;
  const int y = 25378;
  const int z = -10986;
  const int d = 0x128;

  top->start = 1;
  top->xin = x;
  top->yin = y;
  top->zin = z;
  top->d = d;

  int16_t expectedx = (d*x) >> 10;
  int16_t expectedy = (d*y) >> 10;
  int16_t expectedz = (d*z) >> 10;

  printf("Expected: x=%d, y=%d, z=%d\n", expectedx, expectedy, expectedz);

  for (int i = 0; i < 16; i++) {
    top->clk = 0; top->eval(); top->clk = 1; top->eval();
    top->start = 0;
    printf("cycle %d: xout=%d, yout=%d, zout=%d\n", i, (int16_t)top->xout, (int16_t)top->yout, (int16_t)top->zout);
    printf("   internal state: (dshifted=%d xyzshifted = %d %d %d)\n",
      top->rootp->serialmul__DOT__dshifted,
      top->rootp->serialmul__DOT__xshifted,
      top->rootp->serialmul__DOT__yshifted,
      top->rootp->serialmul__DOT__zshifted);
    if (top->done) {
      printf("done next cycle\n");
      break;
    }
  }

  top->clk = 0; top->eval(); top->clk = 1; top->eval();
  printf("output: xout=%d, yout=%d, zout=%d\n", (int16_t)top->xout, (int16_t)top->yout, (int16_t)top->zout);

  delete top;
  return 0;
}