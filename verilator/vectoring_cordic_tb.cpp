#include <stdint.h>
#include "Vvectoring_cordic.h"
#include "Vvectoring_cordic__Syms.h"

int length_cordic(int16_t x, int16_t y, int16_t *x2_, int16_t y2) {
  int x2 = *x2_;
  if (x < 0) { // start in right half-plane
    x = -x;
    x2 = -x2;
  }
  for (int i = 0; i < 8; i++) {
    int t = x;
    int t2 = x2;
    if (y < 0) {
      x -= y >> i;
      y += t >> i;
      x2 -= y2 >> i;
      y2 += t2 >> i;
    } else {
      x += y >> i;
      y -= t >> i;
      x2 += y2 >> i;
      y2 -= t2 >> i;
    }
    printf("reference impl: cycle %d x=%d y=%d x2=%d y2=%d\n", i, x, y, x2, y2);
  }
  // divide by 0.625 as a cheap approximation to the 0.607 scaling factor factor
  // introduced by this algorithm (see https://en.wikipedia.org/wiki/CORDIC)
  *x2_ = (x2 >> 1) + (x2 >> 3);
  return (x >> 1) + (x >> 3);
}

int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv);

  Vvectoring_cordic *top = new Vvectoring_cordic;

  const int x = 5580;
  const int y = -5378;
  const int x2 = 5701;
  const int y2 = 6078;

  top->start = 1;
  top->xin = x;
  top->yin = y;
  top->x2in = x2;
  top->y2in = y2;

  int16_t expectedx, expectedx2;
  expectedx2 = x2;
  expectedx = length_cordic(x, y, &expectedx2, y2);

  printf("Expected: x=%d x2=%d\n", expectedx, expectedx2);

  for (int i = 0; i < 8; i++) {
    top->clk = 0; top->eval(); top->clk = 1; top->eval();
    top->start = 0;
    printf("cycle %d: xout=%d, x2out=%d\n", i, (int16_t)top->xout, (int16_t)top->x2out);
    printf("   internal state: (cycle=%d x=%d y=%d x2=%d y2=%d)\n",
           top->rootp->vectoring_cordic__DOT__cycle,
           top->rootp->vectoring_cordic__DOT__x,
           top->rootp->vectoring_cordic__DOT__y,
           top->rootp->vectoring_cordic__DOT__x2,
           top->rootp->vectoring_cordic__DOT__y2);

    if (top->done) {
      printf("done next cycle\n");
      break;
    }
  }

  top->clk = 0; top->eval(); top->clk = 1; top->eval();
  printf("output: xout=%d x2out=%d\n", (int16_t)top->xout, (int16_t)top->x2out);

  delete top;
  return 0;
}