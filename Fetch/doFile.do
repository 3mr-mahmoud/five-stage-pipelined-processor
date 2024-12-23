vlib work
vmap work work

vcom -2002 instruction_memory.vhd
vcom -2002 TopLevelFetchStage.vhd
vcom -2002 Fetch_tb.vhd


vsim Instruction_Stage_TB

mem load -filltype value -filldata 0001110000000100 -fillradix symbolic /instruction_stage_tb/uut/U_IM/dataMemory(1)
mem load -filltype value -filldata 0001110000000100 -fillradix symbolic /instruction_stage_tb/uut/U_IM/dataMemory(2)
mem load -filltype value -filldata 0001110000000100 -fillradix symbolic /instruction_stage_tb/uut/U_IM/dataMemory(3)
add wave *

run 300ps
