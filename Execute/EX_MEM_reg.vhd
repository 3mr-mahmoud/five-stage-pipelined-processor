library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY EX_MEM_reg IS
    PORT (
        clk, reset, en : in std_logic;
        -- input signals
        stack_in, mem_read_in, mem_write_in, sp_op_in, wb_reg_in,
        wb_port_in, wb_pc_in, in_signal_in : in std_logic;
        rdst_in : in std_logic_vector(2 downto 0);
        sp_memory_value_in, ex_output_in, in_value_in, rsrc2_data_in, pc_in : in std_logic_vector(15 downto 0);
        -- output signals
        stack_out, mem_read_out, mem_write_out, sp_op_out, wb_reg_out,
        wb_port_out, wb_pc_out, in_signal_out : out std_logic;
        rdst_out : out std_logic_vector(2 downto 0);
        sp_memory_value_out, ex_output_out, in_value_out, rsrc2_data_out, pc_out : out std_logic_vector(15 downto 0)
    );
END ENTITY EX_MEM_reg;

ARCHITECTURE EX_MEM_reg_arch OF EX_MEM_reg IS
    -- inertial signals
    signal stack, mem_read, mem_write, sp_op, wb_reg,
        wb_port, wb_pc, in_signal : std_logic;
    signal rdst : std_logic_vector(2 downto 0);
    signal sp_memory_value, ex_output, in_value ,rsrc2_data, pc : std_logic_vector(15 downto 0);
BEGIN
    stack_out <= stack;
    mem_read_out <= mem_read;
    mem_write_out <= mem_write;
    sp_op_out <= sp_op;
    wb_reg_out <= wb_reg;
    wb_port_out <= wb_port;
    wb_pc_out <= wb_pc;
    in_signal_out <= in_signal;
    rdst_out <= rdst;
    sp_memory_value_out <= sp_memory_value;
    ex_output_out <= ex_output;
    in_value_out <= in_value;
    rsrc2_data_out <= rsrc2_data;
    pc_out <= pc;

    process (clk, reset)
    begin
        if reset = '1' then
            stack <= '0';
            mem_read <= '0';
            mem_write <= '0';
            sp_op <= '0';
            wb_reg <= '0';
            wb_port <= '0';
            wb_pc <= '0';
            in_signal <= '0';
            rdst <= (others => '0');
            sp_memory_value <= (others => '0');
            ex_output <= (others => '0');
            in_value <= (others => '0');
            rsrc2_data <= (others => '0');
            pc <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                stack <= stack_in;
                mem_read <= mem_read_in;
                mem_write <= mem_write_in;
                sp_op <= sp_op_in;
                wb_reg <= wb_reg_in;
                wb_port <= wb_port_in;
                wb_pc <= wb_pc_in;
                in_signal <= in_signal_in;
                rdst <= rdst_in;
                sp_memory_value <= sp_memory_value_in;
                ex_output <= ex_output_in;
                in_value <= in_value_in;
                rsrc2_data <= rsrc2_data_in;
                pc <= pc_in;
            end if;
        end if;
    end process;

END ARCHITECTURE EX_MEM_reg_arch;