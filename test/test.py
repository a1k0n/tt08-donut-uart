# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 48MHz
    clock = Clock(dut.clk, 20.83, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Wait for the middle of the first start bit
    await ClockCycles(dut.clk, 200)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    b = 0
    bitcount = 0
    expected = [ord('H'), ord('e')]
    for i in range(20):
        o = dut.uo_out.value&1
        if bitcount == 0:
            if o == 0:
                bitcount = 8
        else:
            b = (b>>1) | (o<<7)
            bitcount -= 1
            if bitcount == 0:
                print('%02x %c' % (b, b))
                assert b == expected[0]
                expected = expected[1:]
        await ClockCycles(dut.clk, 417)

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
