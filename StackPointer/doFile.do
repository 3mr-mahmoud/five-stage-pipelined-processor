vlib work
vmap work work

vcom -2002 stack_pointer.vhd


vsim stack_pointer

add wave *

force -freeze sim:/stack_pointer/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/stack_pointer/reset 1 0

run 300ps

force -freeze sim:/stack_pointer/reset 0 0
force -freeze sim:/stack_pointer/sp_value_decode 16'b0 0
force -freeze sim:/stack_pointer/sp_operation 0 0
force -freeze sim:/stack_pointer/w_en 0 0

run 300ps

force -freeze sim:/stack_pointer/sp_value_decode 16'b0 0
force -freeze sim:/stack_pointer/sp_operation 1 0
force -freeze sim:/stack_pointer/w_en 1 0

run 100ps

force -freeze sim:/stack_pointer/sp_operation 0 0
force -freeze sim:/stack_pointer/w_en 1 0

run 100ps

force -freeze sim:/stack_pointer/sp_operation 0 0
force -freeze sim:/stack_pointer/w_en 0 0
