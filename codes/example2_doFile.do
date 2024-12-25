vlib work
vmap work work




# Compile files in the Decode directory
vcom -2002 ./Decode/control_unit.vhd
vcom -2002 ./Decode/decode_stage.vhd
vcom -2002 ./Decode/ID_EX_reg.vhd
vcom -2002 ./Decode/operand_mux.vhd
vcom -2002 ./Decode/register_file.vhd
vcom -2002 ./Decode/register_file_tb.vhd

# Compile files in the Execute directory
vcom -2002 ./Execute/ALU_unit.vhd
vcom -2002 ./Execute/ALU_unit_tb.vhd
vcom -2002 ./Execute/exception_unit.vhd
vcom -2002 ./Execute/execute_register.vhd
vcom -2002 ./Execute/execute_stage.vhd
vcom -2002 ./Execute/execute_stage_tb.vhd
vcom -2002 ./Execute/EX_MEM_reg.vhd
vcom -2002 ./Execute/flags_register.vhd
vcom -2002 ./Execute/flags_register_tb.vhd
vcom -2002 ./Execute/forward_unit.vhd

# Compile files in the Fetch directory
vcom -2002 ./Fetch/Adder.vhd
vcom -2002 ./Fetch/DFF.vhd
vcom -2002 ./Fetch/Fetch_tb.vhd
vcom -2002 ./Fetch/IF_ID_reg.vhd
vcom -2002 ./Fetch/instruction_memory.vhd
vcom -2002 ./Fetch/PC_Register.vhd
vcom -2002 ./Fetch/TopLevelFetchStage.vhd

# Compile files in the memoryWriteBack directory
vcom -2002 ./memoryWriteBack/memory.vhd
vcom -2002 ./memoryWriteBack/writeBack.vhd
vcom -2002 ./memoryWriteBack/writeBack_tb.vhd

# Compile files in the StackPointer directory
vcom -2002 ./StackPointer/stack_pointer.vhd

# Compile files in the root directory
vcom -2002 ./pipleLine.vhd


vsim pipeline_processor
add wave *

add wave sim:/pipeline_processor/decode_stage_inst/register_file_inst/registers
add wave sim:/pipeline_processor/instruction_stage_inst/*
add wave sim:/pipeline_processor/execute_stage_inst/* 
add wave sim:/pipeline_processor/decode_stage_inst/* 
add wave sim:/pipeline_processor/memory_stage/* 


force -freeze sim:/pipeline_processor/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/pipeline_processor/reset 1 0
force -freeze sim:/pipeline_processor/in_port 16'h0006 0
run 100ps
force -freeze sim:/pipeline_processor/reset 0 0
run 100ps
force -freeze sim:/pipeline_processor/in_port 16'h0020 0
run 800ps

