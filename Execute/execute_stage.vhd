library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY execute_stage IS
    PORT (
        clk : in std_logic;
        -- Inputs from ID/EX register
        stack_in, mem_read_in, mem_write_in, sp_op_in, alu_enable_in, wb_reg_in,
        wb_port_in, wb_pc_in, in_signal_in, branch_signal_in, alu_src_in, 
        rti_signal_in, int_signal_in, carry_in : in std_logic;
        alu_function_in : in std_logic_vector(2 downto 0);
        branch_code_in : in std_logic_vector(1 downto 0);
        rsrc1_in, rsrc2_in, rdst_in : in std_logic_vector(2 downto 0);
        sp_memory_value_in, rsrc1_data_in, rsrc2_data_in, in_value_in, pc_in : in std_logic_vector(15 downto 0);
        -- Other inputs
        immed_value: in std_logic_vector(15 downto 0); -- 16-bit after current instruction
        EX_MEM_WBReg, MEM_WB_WBReg : in  std_logic; -- for forwarding
        EX_MEM_Rdst, MEM_WB_Rdst  : in  std_logic_vector(2 downto 0); -- for forwarding
        EX_MEM_ex_output, MEM_WB_output: in std_logic_vector(15 downto 0); -- for forwarding

        -- Outputs from EX/MEM register
        stack_out, mem_read_out, mem_write_out, sp_op_out, wb_reg_out,
        wb_port_out, wb_pc_out, in_signal_out : out std_logic;
        rdst_out : out std_logic_vector(2 downto 0);
        sp_memory_value_out, ex_output_out, in_value_out, rsrc2_data_out, pc_out : out std_logic_vector(15 downto 0);
        -- Other outputs
        EPC : out std_logic_vector(15 downto 0); -- Exception Program Counter
        exception_sel : out std_logic_vector(1 downto 0); -- Exception Select
        ID_EX_alu_src : out std_logic; -- ALU source
        branch_decision : out std_logic; -- Branch decision
        branch_pc: out std_logic_vector(15 downto 0) -- Branch PC
    );
END ENTITY execute_stage;


ARCHITECTURE execute_arch OF execute_stage IS
    COMPONENT ALU_unit
    GENERIC(
        WIDTH: INTEGER := 16
    );
    PORT (
        enable: IN std_logic;
        ALU_func: IN std_logic_vector(2 downto 0);
        A, B: IN std_logic_vector(WIDTH-1 downto 0);
        ALU_output: OUT std_logic_vector(WIDTH-1 downto 0);
        flags: OUT std_logic_vector(2 downto 0) -- Order: carry, negative, zero
    );
    END COMPONENT;
    COMPONENT EX_MEM_reg
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
    END COMPONENT;
    COMPONENT exception_unit
        PORT (
            memory_read, memory_write, stack_signal: IN std_logic;
            SP_value, ex_output, PC: IN std_logic_vector(15 downto 0);
            exception_sel: OUT std_logic_vector(1 downto 0);
            exception_PC: OUT std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    COMPONENT execute_register
        GENERIC(
            WIDTH: INTEGER := 16
        );
        PORT(
            clk: IN std_logic;
            reset: IN std_logic;
            enable: IN std_logic;
            DataIn: IN std_logic_vector(WIDTH-1 DOWNTO 0);
            DataOut: OUT std_logic_vector(WIDTH-1 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT flags_register
        Port ( 
            clk           : in STD_LOGIC;
            write_enable   : in STD_LOGIC;  
            int_signal     : in STD_LOGIC;  
            rti_signal     : in STD_LOGIC; 
            input_Z        : in STD_LOGIC;
            input_C        : in STD_LOGIC;
            input_N        : in STD_LOGIC;
            zero_flag      : out STD_LOGIC;
            carry_flag     : out STD_LOGIC;
            negative_flag  : out STD_LOGIC
        );
    END COMPONENT;
    COMPONENT forward_unit
        PORT (
            EX_MEM_Rdst  : in  std_logic_vector(2 downto 0);
            MEM_WB_Rdst  : in  std_logic_vector(2 downto 0);
            ID_EX_Rsrc1   : in  std_logic_vector(2 downto 0);
            ID_EX_Rsrc2   : in  std_logic_vector(2 downto 0);
            EX_MEM_WBReg : in  std_logic;
            MEM_WB_WBReg : in  std_logic;
            alu_src       : in std_logic;
            ForwardA      : out std_logic_vector(1 downto 0);
            ForwardB      : out std_logic_vector(1 downto 0)
        );
    END COMPONENT;
    signal selected_flag, carry, reset_reg, branch_decision_temp: std_logic;
    signal ForwardA, ForwardB, exception_sel_temp: std_logic_vector(1 downto 0);
    signal alu_flags, flags_out: std_logic_vector(2 downto 0);
    signal A, B, alu_out, ex_output, EPC_val: std_logic_vector(15 downto 0);
BEGIN
    forwarding: forward_unit PORT MAP(
        EX_MEM_Rdst => EX_MEM_Rdst,
        MEM_WB_Rdst => MEM_WB_Rdst,
        ID_EX_Rsrc1 => rsrc1_in,
        ID_EX_Rsrc2 => rsrc2_in,
        EX_MEM_WBReg => EX_MEM_WBReg,
        MEM_WB_WBReg => MEM_WB_WBReg,
        alu_src => alu_src_in,
        ForwardA => ForwardA,
        ForwardB => ForwardB
    );
    ALU: ALU_unit GENERIC MAP (16) PORT MAP(
        enable => alu_enable_in,
        ALU_func => alu_function_in,
        A => A,
        B => B,
        ALU_output => alu_out,
        flags => alu_flags
    );   
    flags_reg: flags_register PORT MAP(
        clk => clk,
        write_enable => alu_enable_in,
        int_signal => int_signal_in,
        rti_signal => rti_signal_in,
        input_Z => alu_flags(0),
        input_C => carry,
        input_N => alu_flags(1),
        zero_flag => flags_out(0),
        carry_flag => flags_out(2),
        negative_flag => flags_out(1)
    );
    exception: exception_unit PORT MAP(
        memory_read => mem_read_in,
        memory_write => mem_write_in,
        stack_signal => stack_in,
        SP_value => sp_memory_value_in,
        ex_output => ex_output,
        PC => pc_in,
        exception_sel => exception_sel_temp,
        exception_PC => EPC_val
    );
    EPC_reg: execute_register GENERIC MAP (16) PORT MAP(
        clk => clk,
        reset => '0',
        enable => '1',
        DataIn => EPC_val,
        DataOut => EPC
    );
    ex_mem: EX_MEM_reg PORT MAP(
        clk => clk,
        reset => reset_reg,
        en => '1',
        stack_in => stack_in,
        mem_read_in => mem_read_in,
        mem_write_in => mem_write_in,
        sp_op_in => sp_op_in,
        wb_reg_in => wb_reg_in,
        wb_port_in => wb_port_in,
        wb_pc_in => wb_pc_in,
        in_signal_in => in_signal_in,
        rdst_in => rdst_in,
        sp_memory_value_in => sp_memory_value_in,
        ex_output_in => ex_output,
        in_value_in => in_value_in,
        rsrc2_data_in => rsrc2_data_in,
        pc_in => pc_in,
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
        pc_out => pc_out
    );
    with ForwardA select
        A <= rsrc1_data_in when "00",
            EX_MEM_ex_output when "01",
            MEM_WB_output when "10",
            rsrc1_data_in when others;
    with ForwardB select
        B <= rsrc2_data_in when "00",
            EX_MEM_ex_output when "01",
            MEM_WB_output when "10",
            immed_value when others;
    with branch_code_in select
        selected_flag <= '1' when "00",
            alu_flags(0) when "01",
            alu_flags(1) when "10",
            alu_flags(2) when others;
    branch_decision_temp <= selected_flag and branch_signal_in;
    branch_decision <= branch_decision_temp;
    with branch_decision_temp select
        branch_pc <= A when '1',
            pc_in when others;
    with alu_enable_in select
        ex_output <= alu_out when '1',
            B when others;
    ID_EX_alu_src <= alu_src_in;
    carry <= alu_flags(2) or carry_in;
    reset_reg <= exception_sel_temp(0) or exception_sel_temp(1);
    exception_sel <= exception_sel_temp;

END ARCHITECTURE execute_arch;