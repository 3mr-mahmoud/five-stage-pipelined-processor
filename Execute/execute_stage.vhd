LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY execute_stage IS
    PORT (
        clk : IN STD_LOGIC;
        -- Inputs from ID/EX register
        stack_in, mem_read_in, mem_write_in, sp_op_in, alu_enable_in, wb_reg_in,
        wb_port_in, wb_pc_in, in_signal_in, branch_signal_in, alu_src_in,
        rti_signal_in, int_signal_in, carry_in, push_signal_in : IN STD_LOGIC;
        alu_function_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        branch_code_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        rsrc1_in, rsrc2_in, rdst_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        sp_memory_value_in, rsrc1_data_in, rsrc2_data_in, in_value_in, pc_in: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        -- Other inputs
        immed_value : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16-bit after current instruction
        EX_MEM_WBReg, MEM_WB_WBReg : IN STD_LOGIC; -- for forwarding
        EX_MEM_Rdst, MEM_WB_Rdst : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- for forwarding
        EX_MEM_ex_output, MEM_WB_output : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- for forwarding

        -- Outputs from EX/MEM register
        stack_out, mem_read_out, mem_write_out, sp_op_out, wb_reg_out,
        wb_port_out, wb_pc_out, in_signal_out, push_signal_out : OUT STD_LOGIC;
        rdst_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        sp_memory_value_out, ex_output_out, in_value_out, rsrc2_data_out, pc_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        -- Other outputs
        EPC : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- Exception Program Counter
        exception_sel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- Exception Select
        branch_decision : OUT STD_LOGIC; -- Branch decision
        branch_pc : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- Branch PC
        forwarded_rsrc2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) -- Forwarded Rsrc2
    );
END ENTITY execute_stage;
ARCHITECTURE execute_arch OF execute_stage IS
    COMPONENT ALU_unit
        GENERIC (
            WIDTH : INTEGER := 16
        );
        PORT (
            enable : IN STD_LOGIC;
            ALU_func : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            A, B : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
            ALU_output : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
            flags : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) -- Order: carry, negative, zero
        );
    END COMPONENT;
    COMPONENT EX_MEM_reg
        PORT (
            clk, reset, en : IN STD_LOGIC;
            -- input signals
            stack_in, mem_read_in, mem_write_in, sp_op_in, wb_reg_in,
            wb_port_in, wb_pc_in, in_signal_in, push_signal_in : IN STD_LOGIC;
            rdst_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            sp_memory_value_in, ex_output_in, in_value_in, rsrc2_data_in, pc_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            -- output signals
            stack_out, mem_read_out, mem_write_out, sp_op_out, wb_reg_out,
            wb_port_out, wb_pc_out, in_signal_out , push_signal_out : OUT STD_LOGIC;
            rdst_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            sp_memory_value_out, ex_output_out, in_value_out, rsrc2_data_out, pc_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT exception_unit
        PORT (
            memory_read, memory_write, stack_signal : IN STD_LOGIC;
            SP_value, ex_output, PC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            exception_sel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            exception_PC : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT execute_register
        GENERIC (
            WIDTH : INTEGER := 16
        );
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            enable : IN STD_LOGIC;
            DataIn : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
            DataOut : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT flags_register
        PORT (
            clk : IN STD_LOGIC;
            write_enable : IN STD_LOGIC;
            int_signal : IN STD_LOGIC;
            rti_signal : IN STD_LOGIC;
            input_Z : IN STD_LOGIC;
            input_C : IN STD_LOGIC;
            input_N : IN STD_LOGIC;
            zero_flag : OUT STD_LOGIC;
            carry_flag : OUT STD_LOGIC;
            negative_flag : OUT STD_LOGIC
        );
    END COMPONENT;
    COMPONENT forward_unit
        PORT (
            EX_MEM_Rdst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            MEM_WB_Rdst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            ID_EX_Rsrc1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            ID_EX_Rsrc2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            EX_MEM_WBReg : IN STD_LOGIC;
            MEM_WB_WBReg : IN STD_LOGIC;
            ForwardA : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            ForwardB : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
        );
    END COMPONENT;
    SIGNAL selected_flag, carry, reset_reg, branch_decision_temp : STD_LOGIC;
    SIGNAL ForwardA, ForwardB, exception_sel_temp : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL alu_flags, flags_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL A, B, alu_out, ex_output, EPC_val : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL Rsrc2_out : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL flags_enable : STD_LOGIC := '0';
BEGIN
    forwarding : forward_unit PORT MAP(
        EX_MEM_Rdst => EX_MEM_Rdst,
        MEM_WB_Rdst => MEM_WB_Rdst,
        ID_EX_Rsrc1 => rsrc1_in,
        ID_EX_Rsrc2 => rsrc2_in,
        EX_MEM_WBReg => EX_MEM_WBReg,
        MEM_WB_WBReg => MEM_WB_WBReg,
        ForwardA => ForwardA,
        ForwardB => ForwardB
    );
    ALU : ALU_unit GENERIC MAP(
        16) PORT MAP(
        enable => alu_enable_in,
        ALU_func => alu_function_in,
        A => A,
        B => B,
        ALU_output => alu_out,
        flags => alu_flags
    );
    flags_reg : flags_register PORT MAP(
        clk => clk,
        write_enable => flags_enable,
        int_signal => int_signal_in,
        rti_signal => rti_signal_in,
        input_Z => alu_flags(0),
        input_C => carry,
        input_N => alu_flags(1),
        zero_flag => flags_out(0),
        carry_flag => flags_out(2),
        negative_flag => flags_out(1)
    );
    exception : exception_unit PORT MAP(
        memory_read => mem_read_in,
        memory_write => mem_write_in,
        stack_signal => stack_in,
        SP_value => sp_memory_value_in,
        ex_output => ex_output,
        PC => pc_in,
        exception_sel => exception_sel_temp,
        exception_PC => EPC_val
    );
    EPC_reg : execute_register GENERIC MAP(
        16) PORT MAP(
        clk => clk,
        reset => '0',
        enable => '1',
        DataIn => EPC_val,
        DataOut => EPC
    );
    ex_mem : EX_MEM_reg PORT MAP(
        clk => clk,
        reset => reset_reg,
        en => '1',
        stack_in => stack_in,
        mem_read_in => mem_read_in,
        mem_write_in => mem_write_in,
        push_signal_in => push_signal_in,
        sp_op_in => sp_op_in,
        wb_reg_in => wb_reg_in,
        wb_port_in => wb_port_in,
        wb_pc_in => wb_pc_in,
        in_signal_in => in_signal_in,
        rdst_in => rdst_in,
        sp_memory_value_in => sp_memory_value_in,
        ex_output_in => ex_output,
        in_value_in => in_value_in,
        rsrc2_data_in => Rsrc2_out,
        pc_in => pc_in,
        stack_out => stack_out,
        mem_read_out => mem_read_out,
        mem_write_out => mem_write_out,
        sp_op_out => sp_op_out,
        wb_reg_out => wb_reg_out,
        wb_port_out => wb_port_out,
        wb_pc_out => wb_pc_out,
        in_signal_out => in_signal_out,
        push_signal_out => push_signal_out,
        rdst_out => rdst_out,
        sp_memory_value_out => sp_memory_value_out,
        ex_output_out => ex_output_out,
        in_value_out => in_value_out,
        rsrc2_data_out => rsrc2_data_out,
        pc_out => pc_out
    );

    forwarded_rsrc2 <= Rsrc2_out;

    WITH ForwardA SELECT
        A <= rsrc1_data_in WHEN "00",
        EX_MEM_ex_output WHEN "01",
        MEM_WB_output WHEN "10",
        rsrc1_data_in WHEN OTHERS;
    WITH ForwardB SELECT
        Rsrc2_out <= rsrc2_data_in WHEN "00",
        EX_MEM_ex_output WHEN "01",
        MEM_WB_output WHEN "10",
        rsrc2_data_in WHEN OTHERS;
    WITH alu_src_in SELECT
        B <= Rsrc2_out WHEN '0',
        immed_value WHEN OTHERS;
    WITH branch_code_in SELECT
        selected_flag <= '1' WHEN "00",
        alu_flags(0) WHEN "01",
        alu_flags(1) WHEN "10",
        alu_flags(2) WHEN OTHERS;
    branch_decision_temp <= selected_flag AND branch_signal_in;
    branch_decision <= selected_flag AND branch_signal_in;
    WITH branch_decision_temp SELECT
        branch_pc <= A WHEN '1',
        pc_in WHEN OTHERS;
    WITH alu_enable_in SELECT
        ex_output <= alu_out WHEN '1',
        B WHEN OTHERS;
    carry <= alu_flags(2) OR carry_in;
    reset_reg <= exception_sel_temp(0) OR exception_sel_temp(1);
    exception_sel <= exception_sel_temp;
    flags_enable <= alu_enable_in OR carry_in;

END ARCHITECTURE execute_arch;