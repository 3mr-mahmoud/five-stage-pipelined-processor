
vsim -gui work.wb
add wave -position end  sim:/wb/clk
add wave -position end  sim:/wb/inSig
add wave -position end  sim:/wb/inVal
add wave -position end  sim:/wb/memOut
add wave -position end  sim:/wb/memRead
add wave -position end  sim:/wb/muxOut
add wave -position end  sim:/wb/output