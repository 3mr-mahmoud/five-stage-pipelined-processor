vlib work
vmap work work

vcom -2008 operand_mux.vhd
vcom -2008 ID_EX_reg.vhd
vcom -2008 register_file.vhd
vcom -2008 register_file_tb.vhd

vsim register_file_tb
add wave *


run -all