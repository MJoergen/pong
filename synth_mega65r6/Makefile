# Author:  Michael Jørgensen
# Project: XENTA, RCU, Main FPGA
#
# Description: Makefile for generating bitfile for Main FPGA
# Platform: MEGA65

# List of source files
SRC_DIR = ../src
SRC += $(SRC_DIR)/background.vhd
SRC += $(SRC_DIR)/ball_move.vhd
SRC += $(SRC_DIR)/computer_move.vhd
SRC += $(SRC_DIR)/player_move.vhd
SRC += $(SRC_DIR)/pong.vhd
SRC += $(SRC_DIR)/sprite_pkg.vhd


# List of platform specific files
PLATFORM_SRC_DIR = .
SRC += $(PLATFORM_SRC_DIR)/clk_rst.vhd
SRC += $(PLATFORM_SRC_DIR)/mega65kbd_to_matrix.vhd
SRC += $(PLATFORM_SRC_DIR)/mega65r6.vhd
SRC += $(PLATFORM_SRC_DIR)/pong_mega65r6.vhd
SRC += $(PLATFORM_SRC_DIR)/sprite.vhd
SRC += $(PLATFORM_SRC_DIR)/video_modes_pkg.vhd
SRC += $(PLATFORM_SRC_DIR)/video_sync.vhd
SRC += $(PLATFORM_SRC_DIR)/vga_wrapper.vhd

# Top level entity
TOP = pong_mega65r6

################## Don't change anything below here ******************************

# Specify install location of the AMD Vivado tool
VIVADO_DIR = /opt/Xilinx/2025.1/Vivado

PART = xc7a200tfbg484-2

XDC = mega65r6.xdc

OPTIONS += -flatten_hierarchy none

# Generate the bit-file used to configure the FPGA
build/$(TOP).bit: build/$(TOP).tcl
	bash -c "source $(VIVADO_DIR)/settings64.sh ; vivado -mode tcl -source $<"

# Generate the build script used by Vivado
# This is based on:
# https://docs.amd.com/r/2024.1-English/ug892-vivado-design-flows-overview/Using-Non-Project-Mode-Tcl-Commands
build/$(TOP).tcl: Makefile $(SRC) $(XDC)
	mkdir -p build
	echo "# This is a tcl command script for the Vivado tool chain" > $@
	echo "create_project -in_memory" >> $@
	echo "set_property PART $(PART) [current_project]" >> $@
	echo "set_property XPM_LIBRARIES {XPM_CDC XPM_FIFO} [current_project]" >> $@
	echo "read_vhdl -vhdl2008 { $(SRC) }" >> $@
	echo "read_xdc { $(XDC) }" >> $@
	echo "synth_design -top $(TOP) $(OPTIONS)" >> $@
	echo "opt_design" >> $@
	echo "place_design" >> $@
	echo "phys_opt_design" >> $@
	echo "route_design" >> $@
	echo "write_checkpoint -force build/$(TOP).dcp" >> $@
	echo "write_bitstream -bin_file -force build/$(TOP).bit" >> $@
	echo "exit" >> $@

.PHONY: clean
clean:
	rm -rf build
	rm -rf vivado*
	rm -rf .Xil
	rm -rf clockInfo.txt
	rm -rf debug_nets.ltx

