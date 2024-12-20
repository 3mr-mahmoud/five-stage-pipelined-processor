vlib work
vmap work work

vcom -2002 instruction_memory.vhd
vcom -2002 TopLevelFetchStage.vhd
vcom -2002 Fetch_tb.vhd


vsim Instruction_Stage_TB

mem load -filltype value -filldata 0000000000001001 -fillradix symbolic /instruction_stage_tb/uut/U_IM/dataMemory(1)
mem load -filltype value -filldata 0000000011000000 -fillradix symbolic /instruction_stage_tb/uut/U_IM/dataMemory(20)
mem load -filltype value -filldata 0001100000000000 -fillradix symbolic /instruction_stage_tb/uut/U_IM/dataMemory(65530)
mem load -filltype value -filldata 0000000011110000 -fillradix symbolic /instruction_stage_tb/uut/U_IM/dataMemory(65531)
add wave *

run 300ps
