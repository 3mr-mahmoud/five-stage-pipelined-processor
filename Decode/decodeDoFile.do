vlib work
vmap work work

vcom -2002 control_unit.vhd
vcom -2002 operand_mux.vhd
vcom -2002 register_file.vhd
vcom -2002 ID_EX_reg.vhd
vcom -2002 decode_stage.vhd

vsim decode_stage
add wave *


force -freeze sim:/decode_stage/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/decode_stage/write_enable_writeback 0 0
force -freeze sim:/decode_stage/write_address_writeback 000 0
force -freeze sim:/decode_stage/pcIn 16'b0 0
force -freeze sim:/decode_stage/instruction 16'b0 0
force -freeze sim:/decode_stage/stackpointer_value 16'b111 0
force -freeze sim:/decode_stage/reset_decode_execute 0 0
force -freeze sim:/decode_stage/enable_decode_execute 1 0
