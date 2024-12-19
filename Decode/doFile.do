vlib work
vmap work work

vcom -2008 control_unit.vhd

vsim control_unit
add wave *


force -freeze sim:/control_unit/alu_src_execute 0 0
force -freeze sim:/control_unit/opcode 0000000 0
run

force -freeze sim:/control_unit/opcode 0000001 0
run

force -freeze sim:/control_unit/opcode 0000010 0
run

force -freeze sim:/control_unit/opcode 0000011 0
run

force -freeze sim:/control_unit/opcode 0000011 0
run
force -freeze sim:/control_unit/opcode 0000100 0
run
force -freeze sim:/control_unit/opcode 0000101 0
run
force -freeze sim:/control_unit/opcode 0000110 0
run
force -freeze sim:/control_unit/opcode 0000111 0
run
force -freeze sim:/control_unit/opcode 0001000 0
run
force -freeze sim:/control_unit/opcode 0001001 0
run
force -freeze sim:/control_unit/opcode 0001010 0
run
force -freeze sim:/control_unit/opcode 0001011 0
run
force -freeze sim:/control_unit/opcode 0001100 0
run
force -freeze sim:/control_unit/opcode 0001101 0
run
force -freeze sim:/control_unit/opcode 0001110 0
run
force -freeze sim:/control_unit/opcode 0001111 0
run
force -freeze sim:/control_unit/opcode 0010000 0
run
force -freeze sim:/control_unit/opcode 0010001 0
run
force -freeze sim:/control_unit/opcode 0010010 0
run
force -freeze sim:/control_unit/opcode 0010011 0
run
force -freeze sim:/control_unit/opcode 0010100 0
run
force -freeze sim:/control_unit/opcode 0010101 0
run
force -freeze sim:/control_unit/opcode 0010110 0
run
force -freeze sim:/control_unit/opcode 0100000 0
run
force -freeze sim:/control_unit/opcode 1000000 0
run
force -freeze sim:/control_unit/opcode 1100000 0
run
run
run