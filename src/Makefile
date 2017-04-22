project    = pong
top_module = pong
vfiles     = pong.vhd # Top level

vfiles    += vga_controller_640_60.vhd
vfiles    += background.vhd
vfiles    += player.vhd
vfiles    += player_disp.vhd
vfiles    += player_move.vhd
vfiles    += computer.vhd
vfiles    += computer_disp.vhd
vfiles    += computer_move.vhd
vfiles    += ball.vhd
vfiles    += ball_disp.vhd
vfiles    += ball_move.vhd

# Synthesis
vendor     = xilinx
family     = spartan3e
part       = xc3s250e-5-cp132
board      = Basys2
index      = 0
#part       = xc7a35t-1-cpg236
#board      = Basys3

# Simulation
testbench  = $(top_module)_tb
tb_sources = $(testbench).vhd
wave       = $(testbench).ghw
wavesave   = $(testbench).gtkw
unisim_lib = unisim-obj93.cf
#stoptime   = --stop-time=4000us
stoptime   = --stop-time=20ms --assert-level=none

# Host PC application
app_source = $(project).cpp
app_libs   = -ldmgr -ldepp

include xilinx.mk

