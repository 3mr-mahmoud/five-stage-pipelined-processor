LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY execute_stage_tb IS
END ENTITY execute_stage_tb;

ARCHITECTURE behavior OF execute_stage_tb IS

    -- Component declaration for the Unit Under Test (UUT)
    COMPONENT execute_stage
        PORT (
            clk : IN std_logic;
            -- Inputs
            stack_in, mem_read_in, mem_write_in, sp_op_in, alu_enable_in, wb_reg_in,
            wb_port_in, wb_pc_in, in_signal_in, branch_signal_in, alu_src_in, 
            rti_signal_in, int_signal_in, carry_in : IN std_logic;
            alu_function_in : IN std_logic_vector(2 downto 0);
            branch_code_in : IN std_logic_vector(1 downto 0);
            rsrc1_in, rsrc2_in, rdst_in : IN std_logic_vector(2 downto 0);
            sp_memory_value_in, rsrc1_data_in, rsrc2_data_in, in_value_in, pc_in : IN std_logic_vector(15 downto 0);
            immed_value: IN std_logic_vector(15 downto 0);
            EX_MEM_WBReg, MEM_WB_WBReg : IN std_logic;
            EX_MEM_Rdst, MEM_WB_Rdst : IN std_logic_vector(2 downto 0);
            EX_MEM_ex_output, MEM_WB_output: IN std_logic_vector(15 downto 0);

            -- Outputs
            stack_out, mem_read_out, mem_write_out, sp_op_out, wb_reg_out,
            wb_port_out, wb_pc_out, in_signal_out : OUT std_logic;
            rdst_out : OUT std_logic_vector(2 downto 0);
            sp_memory_value_out, ex_output_out, in_value_out, rsrc2_data_out, pc_out : OUT std_logic_vector(15 downto 0);
            EPC : OUT std_logic_vector(15 downto 0);
            exception_sel : OUT std_logic_vector(1 downto 0);
            ID_EX_alu_src : OUT std_logic;
            branch_decision : OUT std_logic;
            branch_pc : OUT std_logic_vector(15 downto 0)
        );
    END COMPONENT;

    -- Signals to connect to UUT
    SIGNAL clk : std_logic := '0';
    SIGNAL stack_in, mem_read_in, mem_write_in, sp_op_in, alu_enable_in, wb_reg_in : std_logic := '0';
    SIGNAL wb_port_in, wb_pc_in, in_signal_in, branch_signal_in, alu_src_in : std_logic := '0';
    SIGNAL rti_signal_in, int_signal_in, carry_in : std_logic := '0';
    SIGNAL alu_function_in : std_logic_vector(2 downto 0) := (others => '0');
    SIGNAL branch_code_in : std_logic_vector(1 downto 0) := (others => '0');
    SIGNAL rsrc1_in, rsrc2_in, rdst_in : std_logic_vector(2 downto 0) := (others => '0');
    SIGNAL sp_memory_value_in, rsrc1_data_in, rsrc2_data_in, in_value_in, pc_in : std_logic_vector(15 downto 0) := (others => '0');
    SIGNAL immed_value : std_logic_vector(15 downto 0) := (others => '0');
    SIGNAL EX_MEM_WBReg, MEM_WB_WBReg : std_logic := '0';
    SIGNAL EX_MEM_Rdst, MEM_WB_Rdst : std_logic_vector(2 downto 0) := (others => '0');
    SIGNAL EX_MEM_ex_output, MEM_WB_output : std_logic_vector(15 downto 0) := (others => '0');

    -- Outputs
    SIGNAL stack_out, mem_read_out, mem_write_out, sp_op_out, wb_reg_out : std_logic;
    SIGNAL wb_port_out, wb_pc_out, in_signal_out : std_logic;
    SIGNAL rdst_out : std_logic_vector(2 downto 0);
    SIGNAL sp_memory_value_out, ex_output_out, in_value_out, rsrc2_data_out, pc_out : std_logic_vector(15 downto 0);
    SIGNAL EPC : std_logic_vector(15 downto 0);
    SIGNAL exception_sel : std_logic_vector(1 downto 0);
    SIGNAL ID_EX_alu_src : std_logic;
    SIGNAL branch_decision : std_logic;
    SIGNAL branch_pc : std_logic_vector(15 downto 0);

    -- Clock period definition
    CONSTANT clk_period : time := 30 ps;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: execute_stage PORT MAP (
        clk => clk,
        stack_in => stack_in,
        mem_read_in => mem_read_in,
        mem_write_in => mem_write_in,
        sp_op_in => sp_op_in,
        alu_enable_in => alu_enable_in,
        wb_reg_in => wb_reg_in,
        wb_port_in => wb_port_in,
        wb_pc_in => wb_pc_in,
        in_signal_in => in_signal_in,
        branch_signal_in => branch_signal_in,
        alu_src_in => alu_src_in,
        rti_signal_in => rti_signal_in,
        int_signal_in => int_signal_in,
        carry_in => carry_in,
        alu_function_in => alu_function_in,
        branch_code_in => branch_code_in,
        rsrc1_in => rsrc1_in,
        rsrc2_in => rsrc2_in,
        rdst_in => rdst_in,
        sp_memory_value_in => sp_memory_value_in,
        rsrc1_data_in => rsrc1_data_in,
        rsrc2_data_in => rsrc2_data_in,
        in_value_in => in_value_in,
        pc_in => pc_in,
        immed_value => immed_value,
        EX_MEM_WBReg => EX_MEM_WBReg,
        MEM_WB_WBReg => MEM_WB_WBReg,
        EX_MEM_Rdst => EX_MEM_Rdst,
        MEM_WB_Rdst => MEM_WB_Rdst,
        EX_MEM_ex_output => EX_MEM_ex_output,
        MEM_WB_output => MEM_WB_output,
        stack_out => stack_out,
        mem_read_out => mem_read_out,
        mem_write_out => mem_write_out,
        sp_op_out => sp_op_out,
        wb_reg_out => wb_reg_out,
        wb_port_out => wb_port_out,
        wb_pc_out => wb_pc_out,
        in_signal_out => in_signal_out,
        rdst_out => rdst_out,
        sp_memory_value_out => sp_memory_value_out,
        ex_output_out => ex_output_out,
        in_value_out => in_value_out,
        rsrc2_data_out => rsrc2_data_out,
        pc_out => pc_out,
        EPC => EPC,
        exception_sel => exception_sel,
        ID_EX_alu_src => ID_EX_alu_src,
        branch_decision => branch_decision,
        branch_pc => branch_pc
    );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize Inputs
        stack_in <= '0';
        mem_read_in <= '0';
        mem_write_in <= '0';
        sp_op_in <= '0';
        alu_enable_in <= '0';
        wb_reg_in <= '0';
        wb_port_in <= '0';
        wb_pc_in <= '0';
        in_signal_in <= '0';
        branch_signal_in <= '0';
        alu_src_in <= '0';
        rti_signal_in <= '0';
        int_signal_in <= '0';
        carry_in <= '0';
        alu_function_in <= "000";
        branch_code_in <= "00";
        rsrc1_in <= "000";
        rsrc2_in <= "000";
        rdst_in <= "000";
        sp_memory_value_in <= (others => '0');
        rsrc1_data_in <= (others => '0');
        rsrc2_data_in <= (others => '0');
        in_value_in <= (others => '0');
        pc_in <= (others => '0');
        immed_value <= (others => '0');
        EX_MEM_WBReg <= '0';
        MEM_WB_WBReg <= '0';
        EX_MEM_Rdst <= "000";
        MEM_WB_Rdst <= "000";
        EX_MEM_ex_output <= (others => '0');
        MEM_WB_output <= (others => '0');

        -- Wait 100 ns for global reset to finish
        wait for 100 ps;

        -- Apply Test Vectors
        alu_enable_in <= '1';
        alu_function_in <= "001"; -- Example ALU operation
        rsrc1_data_in <= x"000F";
        rsrc2_data_in <= x"0001";
        immed_value <= x"0010";
        wait for clk_period * 2;

        alu_enable_in <= '0';
        wait for clk_period * 2;

        alu_enable_in <= '1';
        alu_function_in <= "010"; -- Example ALU operation
        rsrc2_data_in <= x"0000";
        wait for clk_period * 2;
        -- Test Branch Decision
        branch_signal_in <= '1';
        branch_code_in <= "01"; -- Test zero flag
        wait for clk_period * 2;

        -- Test Exception
        pc_in <= x"0001";
        sp_memory_value_in <= x"1000";
        stack_in <= '1';
        wait for clk_period * 2;
        
        -- End simulation
        wait;
    end process;

END ARCHITECTURE behavior;
