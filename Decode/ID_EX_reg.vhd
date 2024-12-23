
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ID_EX_REGISTER is
    port (
        clk, reset, en : in std_logic;
        -- Input signals
        stack_in, mem_read_in, mem_write_in, sp_op_in, alu_enable_in, wb_reg_in,
        wb_port_in, wb_pc_in, in_signal_in, branch_signal_in, alu_src_in, 
        rti_signal_in, int_signal_in, carry_in, call_signal_in , push_signal_in : in std_logic;
        alu_function_in : in std_logic_vector(2 downto 0);
        branch_code_in : in std_logic_vector(1 downto 0);
        rsrc1_in, rsrc2_in, rdst_in : in std_logic_vector(2 downto 0);
        sp_memory_value_in, rsrc1_data_in, rsrc2_data_in, in_value_in, pc_in : in std_logic_vector(15 downto 0);
        -- Output signals
        stack_out, mem_read_out, mem_write_out, sp_op_out, alu_enable_out, wb_reg_out,
        wb_port_out, wb_pc_out, in_signal_out, branch_signal_out, alu_src_out, 
        rti_signal_out, int_signal_out, carry_out, call_signal_out, push_signal_out : out std_logic;
        alu_function_out : out std_logic_vector(2 downto 0);
        branch_code_out : out std_logic_vector(1 downto 0);
        rsrc1_out, rsrc2_out, rdst_out : out std_logic_vector(2 downto 0);
        sp_memory_value_out, rsrc1_data_out, rsrc2_data_out, in_value_out, pc_out : out std_logic_vector(15 downto 0)
    );
end entity ID_EX_REGISTER;

architecture ID_EX_REGISTER_ARCHITECTURE of ID_EX_REGISTER is
    -- Internal signals
    signal stack, mem_read, mem_write, sp_op, alu_enable, wb_reg,
           wb_port, wb_pc, in_signal, branch_signal, alu_src, 
           rti_signal, int_signal, carry, call_signal, push_signal : std_logic;
    signal alu_function : std_logic_vector(2 downto 0);
    signal branch_code : std_logic_vector(1 downto 0);
    signal rsrc1, rsrc2, rdst : std_logic_vector(2 downto 0);
    signal sp_memory_value, rsrc1_data, rsrc2_data, in_value, pc : std_logic_vector(15 downto 0);
begin
    -- Output assignments with enable signal
   stack_out <= stack;
    mem_read_out <= mem_read;
    mem_write_out <= mem_write;
    sp_op_out <= sp_op;
    alu_enable_out <= alu_enable;
    wb_reg_out <= wb_reg;
    wb_port_out <= wb_port;
    wb_pc_out <= wb_pc;
    in_signal_out <= in_signal;
    branch_signal_out <= branch_signal;
    alu_src_out <= alu_src;
    rti_signal_out <= rti_signal;
    int_signal_out <= int_signal;
    carry_out <= carry;
    alu_function_out <= alu_function;
    branch_code_out <= branch_code;
    rsrc1_out <= rsrc1;
    rsrc2_out <= rsrc2;
    rdst_out <= rdst;
    sp_memory_value_out <= sp_memory_value;
    rsrc1_data_out <= rsrc1_data;
    rsrc2_data_out <= rsrc2_data;
    in_value_out <= in_value;
    pc_out <= pc;

    call_signal_out <= call_signal;
    push_signal_out <= push_signal;


    process (clk, reset)
    begin
        if reset = '1' then
            stack <= '0';
            mem_read <= '0';
            mem_write <= '0';
            sp_op <= '0';
            alu_enable <= '0';
            wb_reg <= '0';
            wb_port <= '0';
            wb_pc <= '0';
            in_signal <= '0';
            branch_signal <= '0';
            alu_src <= '0';
            rti_signal <= '0';
            int_signal <= '0';
            carry <= '0';
            alu_function <= (others => '0');
            branch_code <= (others => '0');
            rsrc1 <= (others => '0');
            rsrc2 <= (others => '0');
            rdst <= (others => '0');
            sp_memory_value <= (others => '0');
            rsrc1_data <= (others => '0');
            rsrc2_data <= (others => '0');
            in_value <= (others => '0');
            call_signal <= '0';
            push_signal <= '0';
            pc <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                -- Update signals with input values
                stack <= stack_in;
                mem_read <= mem_read_in;
                mem_write <= mem_write_in;
                sp_op <= sp_op_in;
                alu_enable <= alu_enable_in;
                wb_reg <= wb_reg_in;
                wb_port <= wb_port_in;
                wb_pc <= wb_pc_in;
                in_signal <= in_signal_in;
                branch_signal <= branch_signal_in;
                alu_src <= alu_src_in;
                rti_signal <= rti_signal_in;
                int_signal <= int_signal_in;
                carry <= carry_in;
                alu_function <= alu_function_in;
                branch_code <= branch_code_in;
                rsrc1 <= rsrc1_in;
                rsrc2 <= rsrc2_in;
                rdst <= rdst_in;
                call_signal <= call_signal_in;
                push_signal <= push_signal_in;
                sp_memory_value <= sp_memory_value_in;
                rsrc1_data <= rsrc1_data_in;
                rsrc2_data <= rsrc2_data_in;
                in_value <= in_value_in;
                pc <= pc_in;
            end if;
        end if;
    end process;
end architecture ID_EX_REGISTER_ARCHITECTURE;


