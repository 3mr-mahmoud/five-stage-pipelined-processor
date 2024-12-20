library IEEE;
use IEEE.std_logic_1164.all;

entity pipeline_processor is
    port (
        clk : in std_logic;
        reset : in std_logic;
        in_port: in std_logic_vector(15 downto 0);
        out_port: out std_logic_vector(15 downto 0)
    );
end entity;

architecture Behavioral of pipeline_processor is

    component Instruction_Stage IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC; -- Reset input
        Src2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        from_ports : IN STD_LOGIC;
        Call_Signal : IN STD_LOGIC;
        Branch_PC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        Branch_Decision : IN STD_LOGIC;
        Exception_Handling : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        RET_Signal, RTI_Signal : IN STD_LOGIC;
        WB_Date : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        WB_PC : IN STD_LOGIC;
        alu_src : IN STD_LOGIC;
        next_PC : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
    END component;

    component decode_stage IS
    PORT (
        clk: IN std_logic;
        write_enable_writeback: IN std_logic;
        write_address_writeback: IN std_logic_vector(2 downto 0);
        write_data_writeback: IN std_logic_vector(15 downto 0);
        pcIn: IN std_logic_vector(15 downto 0);
        input_value: IN std_logic_vector(15 downto 0);
        instruction: IN std_logic_vector(15 downto 0);
        stackpointer_value: IN std_logic_vector(15 downto 0);
        reset_decode_execute: IN std_logic;
        enable_decode_execute: IN std_logic;
        -- Output signals
        stack, mem_read, mem_write, sp_op, alu_enable, wb_reg,
        wb_port, wb_pc, in_signal, branch_signal, alu_src, 
        rti_signal, int_signal, carry : out std_logic;
        alu_function : out std_logic_vector(2 downto 0);
        branch_code : out std_logic_vector(1 downto 0);
        rsrc1, rsrc2, rdst : out std_logic_vector(2 downto 0);
        sp_memory_value, rsrc1_data, rsrc2_data, in_value, pc : out std_logic_vector(15 downto 0);
        call_signal: out std_logic;

        rsrc2_out: out std_logic_vector(15 downto 0);
        ret_signal: out std_logic
    );
    end component;

    component execute_stage is
        port (
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
            branch_decision : out std_logic; -- Branch decision
            branch_pc: out std_logic_vector(15 downto 0) -- Branch PC
        );
    end component;

    component memory is 
        port (
            clk: in std_logic;
            stackSignal: in std_logic;
            memRead: in std_logic;
            memWrite: in std_logic;
            SPOperation: in std_logic;
            SPMemoryValue: in std_logic_vector(15 downto 0);
            ex_output: in std_logic_vector(15 downto 0);
            WBReg: inout std_logic;
            WBPort: inout std_logic;
            WBPC: inout std_logic;
            rDest: inout std_logic_vector(2 downto 0);
            inSig: in std_logic;
            inVal: in std_logic_vector(15 downto 0);
            rSrcData2: in std_logic_vector(15 downto 0);
            PC: in std_logic_vector(15 downto 0);
            INTSign: in std_logic;
            memOut: out std_logic_vector(15 downto 0)
        );
    end component;

    component WB is 
        port (
            clk: in std_logic;
            wbReg: inout std_logic;
            rDest: inout std_logic_vector(2 downto 0);
            wbOutEn: inout std_logic;
            wbPC: inout std_logic;
        
            inSig: inout std_logic;
            memRead: inout std_logic;
    
            inVal: inout std_logic_vector(15 downto 0);
            memOut: inout std_logic_vector(15 downto 0);
            ex_output: inout std_logic_vector(15 downto 0);
    
            muxOut: out std_logic_vector(15 downto 0)
        );
    end component;

    signal rsrc2_out_wire: std_logic_vector(15 downto 0);
    signal ret_signal: std_logic;

    -- signal write_enable_writeback: std_logic;
    -- signal write_address_writeback: std_logic_vector(2 downto 0);
    -- signal write_data_writeback:  std_logic_vector(15 downto 0);
    signal pcIn:  std_logic_vector(15 downto 0);
    -- signal input_value: std_logic_vector(15 downto 0);
    signal instruction: std_logic_vector(15 downto 0);
    signal stackpointer_value: std_logic_vector(15 downto 0);
    signal reset_decode_execute: std_logic;
    signal call: std_logic;
    -- signal enable_decode_execute: std_logic;



    signal ex_stack_in, ex_mem_read_in, ex_mem_write_in, ex_sp_op_in, ex_alu_enable_in, ex_wb_reg_in,
    ex_wb_port_in, ex_wb_pc_in, ex_in_signal_in, ex_branch_signal_in, ex_alu_src_in, 
    ex_rti_signal_in, ex_int_signal_in, ex_carry_in : std_logic;
    signal ex_alu_function_in : std_logic_vector(2 downto 0);
    signal ex_branch_code_in : std_logic_vector(1 downto 0);
    signal ex_rsrc1_in, ex_rsrc2_in, ex_rdst_in : std_logic_vector(2 downto 0);
    signal ex_sp_memory_value_in, ex_rsrc1_data_in, ex_rsrc2_data_in, ex_in_value_in, ex_pc_in : std_logic_vector(15 downto 0);

    signal ex_immed_value: std_logic_vector(15 downto 0);
    signal EX_MEM_WBReg, MEM_WB_WBReg :  std_logic;
    signal EX_MEM_Rdst, MEM_WB_Rdst  :  std_logic_vector(2 downto 0);
    signal EX_MEM_ex_output, MEM_WB_output: std_logic_vector(15 downto 0);

    signal ex_stack_out, ex_mem_read_out, ex_mem_write_out, ex_sp_op_out, ex_wb_reg_out,
    ex_wb_port_out, ex_wb_pc_out, ex_in_signal_out : std_logic;
    signal ex_rdst_out : std_logic_vector(2 downto 0);
    signal ex_sp_memory_value_out, ex_output_out, ex_in_value_out, ex_rsrc2_data_out, ex_pc_out : std_logic_vector(15 downto 0);

    signal EPC : std_logic_vector(15 downto 0); 
    signal exception_sel : std_logic_vector(1 downto 0);
    signal branch_decision : std_logic;
    signal branch_pc: std_logic_vector(15 downto 0);

    signal memOut: std_logic_vector(15 downto 0);
    signal muxOut: std_logic_vector(15 downto 0);


begin

    reset_decode_execute <= branch_decision or exception_sel(0) or exception_sel(1);

    instruction_stage_inst: Instruction_Stage port map (
        clk => clk,
        reset => '1',
        Src2 => rsrc2_out_wire,
        from_ports => reset,
        Call_Signal => call,
        Branch_PC => branch_pc,
        Branch_Decision => branch_decision,
        Exception_Handling => exception_sel,
        RET_Signal => ret_signal,
        RTI_Signal => ex_rti_signal_in,
        WB_Date => memOut,
        WB_PC => ex_wb_pc_out,
        alu_src => ex_alu_src_in,
        next_PC => pcIn,
        instruction => instruction
    );

    decode_stage_inst: decode_stage port map (
        clk => clk,
        write_enable_writeback => ex_wb_reg_out,
        write_address_writeback => ex_rdst_out,
        write_data_writeback => muxOut,
        pcIn => pcIn,
        input_value => in_port,
        instruction => instruction,
        stackpointer_value => stackpointer_value,
        reset_decode_execute => reset_decode_execute,
        enable_decode_execute => '1',
        stack => ex_stack_in,
        mem_read => ex_mem_read_in,
        mem_write => ex_mem_write_in,
        sp_op => ex_sp_op_in,
        alu_enable => ex_alu_enable_in,
        wb_reg => ex_wb_reg_in,
        wb_port => ex_wb_port_in,
        wb_pc => ex_wb_pc_in,
        in_signal => ex_in_signal_in,
        branch_signal => ex_branch_signal_in,
        alu_src => ex_alu_src_in,
        rti_signal => ex_rti_signal_in,
        int_signal => ex_int_signal_in,
        carry => ex_carry_in,
        alu_function => ex_alu_function_in,
        branch_code => ex_branch_code_in,
        rsrc1 => ex_rsrc1_in,
        rsrc2 => ex_rsrc2_in,
        rdst => ex_rdst_in,
        sp_memory_value => ex_sp_memory_value_in,
        rsrc1_data => ex_rsrc1_data_in,
        rsrc2_data => ex_rsrc2_data_in,
        in_value => ex_in_value_in,
        pc => ex_pc_in,
        call_signal => call,
        rsrc2_out => rsrc2_out_wire,
        ret_signal => ret_signal
    );

    execute_stage_inst: execute_stage port map (
        clk => clk,
        stack_in => ex_stack_in,
        mem_read_in => ex_mem_read_in,
        mem_write_in => ex_mem_write_in,
        sp_op_in => ex_sp_op_in,
        alu_enable_in => ex_alu_enable_in,
        wb_reg_in => ex_wb_reg_in,
        wb_port_in => ex_wb_port_in,
        wb_pc_in => ex_wb_pc_in,
        in_signal_in => ex_in_signal_in,
        branch_signal_in => ex_branch_signal_in,
        alu_src_in => ex_alu_src_in,
        rti_signal_in => ex_rti_signal_in,
        int_signal_in => ex_int_signal_in,
        carry_in => ex_carry_in,
        alu_function_in => ex_alu_function_in,
        branch_code_in => ex_branch_code_in,
        rsrc1_in => ex_rsrc1_in,
        rsrc2_in => ex_rsrc2_in,
        rdst_in => ex_rdst_in,
        sp_memory_value_in => ex_sp_memory_value_in,
        rsrc1_data_in => ex_rsrc1_data_in,
        rsrc2_data_in => ex_rsrc2_data_in,
        in_value_in => ex_in_value_in,
        pc_in => ex_pc_in,
        immed_value => ex_immed_value,
        EX_MEM_WBReg => EX_MEM_WBReg,
        MEM_WB_WBReg => MEM_WB_WBReg,
        EX_MEM_Rdst => EX_MEM_Rdst,
        MEM_WB_Rdst => MEM_WB_Rdst,
        EX_MEM_ex_output => EX_MEM_ex_output,
        MEM_WB_output => MEM_WB_output,
        stack_out => ex_stack_out,
        mem_read_out => ex_mem_read_out,
        mem_write_out => ex_mem_write_out,
        sp_op_out => ex_sp_op_out,
        wb_reg_out => ex_wb_reg_out,
        wb_port_out => ex_wb_port_out,
        wb_pc_out => ex_wb_pc_out,
        in_signal_out => ex_in_signal_out,
        rdst_out => ex_rdst_out,
        sp_memory_value_out => ex_sp_memory_value_out,
        ex_output_out => ex_output_out,
        in_value_out => ex_in_value_out,
        rsrc2_data_out => ex_rsrc2_data_out,
        pc_out => ex_pc_out,
        EPC => EPC,
        exception_sel => exception_sel,
        branch_decision => branch_decision,
        branch_pc => branch_pc
    );

    memory_stage: memory port map (
        clk => clk,
        stackSignal => ex_stack_out,
        memRead => ex_mem_read_out,
        memWrite => ex_mem_write_out,
        SPOperation => ex_sp_op_out,
        SPMemoryValue => ex_sp_memory_value_out,
        ex_output => ex_output_out,
        WBReg => ex_wb_reg_out,
        WBPort => ex_wb_port_out,
        WBPC => ex_wb_pc_out,
        rDest => ex_rdst_out,
        inSig => ex_in_signal_out,
        inVal => ex_in_value_out,
        rSrcData2 => ex_rsrc2_data_out,
        PC => ex_pc_out,
        INTSign => ex_int_signal_in,
        memOut => memOut
    );

    write_back_stage: WB port map (
        clk => clk,
        wbReg => ex_wb_reg_out,
        rDest => ex_rdst_out,
        wbOutEn => ex_wb_port_out,
        wbPC => ex_wb_pc_out,
        inSig => ex_in_signal_out,
        memRead => ex_mem_read_out,
        inVal => ex_in_value_out,
        memOut => memOut,
        ex_output => ex_output_out,
        muxOut => muxOut
    );
    
    out_port <= muxOut when ex_wb_port_out = '1' else (others => '0');
end architecture;