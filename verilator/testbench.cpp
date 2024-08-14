#include <stdio.h>

#include "Vtop.h"
#include "verilated.h"

const int clock_div = 2;

enum UartState {
    IDLE,
    START_BIT,
    DATA_BITS,
    STOP_BIT
};

class UARTStateMachine {
public:
    UARTStateMachine(int clock_divider) : clock_divider_(clock_divider), state_(IDLE), bit_counter_(0), data_(0), clk_(0) {}

    void processBit(bool bit) {
        clk_++;
        if (state_ != IDLE && clk_ < clock_divider_) {
            return;
        }
        clk_ = 0;
        switch (state_) {
            case IDLE:
                if (!bit) {  // Start bit
                    state_ = DATA_BITS;
                    bit_counter_ = 0;
                    data_ = 0;
                }
                break;
            case DATA_BITS:
                data_ |= (bit << bit_counter_);
                bit_counter_++;
                if (bit_counter_ == 8) {
                    state_ = STOP_BIT;
                }
                break;
            case STOP_BIT:
                if (bit) {
                    putchar(data_ ^ 0xff);
                }
                state_ = IDLE;
                break;
        }
    }

    void reset() {
        state_ = IDLE;
        bit_counter_ = 0;
        data_ = 0;
        clk_ = 0;
        printf("--reset--\n");
    }

private:
    int clock_divider_;
    UartState state_;
    int bit_counter_;
    int data_;
    int clk_;
};

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    Vtop uart;

    // Initialize UART state machine with a clock divider of 16
    UARTStateMachine rx(clock_div);

    // Rest of the code...

    uart.nrst = 0;

    // Run for a certain number of clock cycles
    for (int i = 0; i < 10000 * clock_div; i++) {
        if (i == 10) {
            uart.nrst = 1;  // Release reset after a few cycles
            rx.reset();
        }

        // Toggle clock
        uart.clk = !uart.clk;
        uart.eval();

        if (uart.clk) {
            // Sample the input bit and process it
            bool input_bit = uart.tx;
            //putchar('0' + input_bit);
            rx.processBit(input_bit);
        }
    }
    printf("\n");

    return 0;
}
