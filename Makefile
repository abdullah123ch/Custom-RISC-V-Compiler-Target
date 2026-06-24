# =================================================================================
# RISC-V Single Cycle Processor Makefile
# =================================================================================

# Tools
VLOG = vlog
VSIM = vsim
GTKWAVE = gtkwave

# Directories
RTL_DIR = src
TB_DIR  = sim
BUILD_DIR = build

# Top module inside the testbench
TOP_TB = testbench

# Files (Referenced from inside the build directory)
RTL_FILES = ../$(RTL_DIR)/*.sv
TB_FILES  = ../$(TB_DIR)/testbench.sv

# Default target
all: run

# =================================================================================
# Run Simulation
# =================================================================================
run:
	@mkdir -p $(BUILD_DIR)
	@# Uncomment the next line if you are loading memory from a hex file
	@# cp program.hex $(BUILD_DIR)/ 2>/dev/null || true
	cd $(BUILD_DIR) && \
	vlib work && \
	$(VLOG) +incdir+../$(RTL_DIR) $(RTL_FILES) $(TB_FILES) && \
	$(VSIM) -c $(TOP_TB) -do "run -all; quit"

# =================================================================================
# View Waveforms (Requires $dumpfile and $dumpvars in TB)
# =================================================================================
wave:
	cd $(BUILD_DIR) && \
	$(GTKWAVE) dump.vcd wave.gtkw

# =================================================================================
# Clean Build Directory
# =================================================================================
clean:
	rm -rf $(BUILD_DIR)