# Verilator executable
VERILATOR = verilator

# Verilog source file
VERILOG_SRC = ../src/top.v ../src/UART_Transmitter.v

# Testbench source file
TESTBENCH_SRC = testbench.cpp

# Output directory
OUTPUT_DIR = obj_dir

# Verilator flags
VERILATOR_FLAGS = --cc --exe --trace

# Targets
all: $(OUTPUT_DIR)/Vtop

$(OUTPUT_DIR)/Vtop: $(VERILOG_SRC) $(TESTBENCH_SRC)
	$(VERILATOR) $(VERILATOR_FLAGS) $(VERILOG_SRC) $(TESTBENCH_SRC)
	make -C $(OUTPUT_DIR) -f Vtop.mk

clean:
	rm -rf $(OUTPUT_DIR)

.PHONY: all clean
