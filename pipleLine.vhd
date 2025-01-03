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
        stack_value_fetch_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        stack_value_fetch_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
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
        reset: IN std_logic;
        write_enable_writeback: IN std_logic;
        write_address_writeback: IN std_logic_vector(2 downto 0);
        write_data_writeback: IN std_logic_vector(15 downto 0);
        pcIn: IN std_logic_vector(15 downto 0);
        input_value: IN std_logic_vector(15 downto 0);
        instruction: IN std_logic_vector(15 downto 0);
        stackpointer_value: IN std_logic_vector(15 downto 0);
        stack_value_fetch: IN std_logic_vector(15 downto 0);
        reset_decode_execute: IN std_logic;
        enable_decode_execute: IN std_logic;
        -- Output signals
        stack_immediate, stack_op_immediate : out std_logic;
        stack, mem_read, mem_write, sp_op, alu_enable, wb_reg,
        wb_port, wb_pc, in_signal, branch_signal, alu_src, 
        rti_signal, int_signal, carry, push_signal : out std_logic;
        alu_function : out std_logic_vector(2 downto 0);
        branch_code : out std_logic_vector(1 downto 0);
        rsrc1, rsrc2, rdst : out std_logic_vector(2 downto 0);
        sp_memory_value, rsrc1_data, rsrc2_data, in_value, pc : out std_logic_vector(15 downto 0);
        call_signal: out std_logic;

        rsrc2_out: out std_logic_vector(15 downto 0);
        ret_signal, alu_src_immed: out std_logic
    );
    end component;

    component execute_stage is
        port (
            clk : in std_logic;
            -- Inputs from ID/EX register
            stack_in, mem_read_in, mem_write_in, sp_op_in, alu_enable_in, wb_reg_in,
            wb_port_in, wb_pc_in, in_signal_in, branch_signal_in, alu_src_in, 
            rti_signal_in, int_signal_in, carry_in, push_signal_in : in std_logic;
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
            wb_port_out, wb_pc_out, in_signal_out , push_signal_out : out std_logic;
            rdst_out : out std_logic_vector(2 downto 0);
            sp_memory_value_out, ex_output_out, in_value_out, rsrc2_data_out, pc_out : out std_logic_vector(15 downto 0);
            -- Other outputs
            EPC : out std_logic_vector(15 downto 0); -- Exception Program Counter
            exception_sel : out std_logic_vector(1 downto 0); -- Exception Select
            branch_decision : out std_logic; -- Branch decision
            branch_pc: out std_logic_vector(15 downto 0); -- Branch PC
            forwarded_rsrc2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    end component;

    component memory is 
        port (
            clk: in std_logic;
            stackSignal: in std_logic;
            memRead_in: in std_logic;
            memRead_out: out std_logic;
            memWrite: in std_logic;
            SPOperation: in std_logic;
            SPMemoryValue: in std_logic_vector(15 downto 0);
            ex_output_in: in std_logic_vector(15 downto 0);
            ex_output_out: out std_logic_vector(15 downto 0);
            WBReg_in: in std_logic;
            WBReg_out: out std_logic;
            WBPort_in: in std_logic;
            WBPort_out: out std_logic;
            WBPC_in: in std_logic;
            WBPC_out: out std_logic;
            rDest_in: in std_logic_vector(2 downto 0);
            rDest_out: out std_logic_vector(2 downto 0);
            inSig_in: in std_logic;
            inSig_out: out std_logic;
            inVal_in: in std_logic_vector(15 downto 0);
            inVal_out: out std_logic_vector(15 downto 0);
            rSrcData2: in std_logic_vector(15 downto 0);
            PC: in std_logic_vector(15 downto 0);
            memOut: out std_logic_vector(15 downto 0);
            enable: in std_logic;
            push_signal: in std_logic
        );
    end component;

    component WB is 
        port (
            clk: in std_logic;
            wbReg: in std_logic;
            rDest: in std_logic_vector(2 downto 0);
            wbOutEn: in std_logic;
            wbPC: in std_logic;
        
            inSig: in std_logic;
            memRead: in std_logic;
    
            inVal: in std_logic_vector(15 downto 0);
            memOut: in std_logic_vector(15 downto 0);
            ex_output: in std_logic_vector(15 downto 0);
    
            muxOut: out std_logic_vector(15 downto 0)
        );
    end component;


    component stack_pointer is
        Port (
            clk           : in  std_logic;         
            reset         : in  std_logic;  
            sp_operation  : in  std_logic;         
            w_en          : in  std_logic;         
            sp_value_decode   : in  std_logic_vector(15 downto 0);
            sp_memory_out : out std_logic_vector(15 downto 0)
        );
    end component;
    signal out_port_reg: std_logic_vector(15 downto 0);
    signal rsrc2_out_wire: std_logic_vector(15 downto 0);
    signal rsrc2_toberemove: std_logic_vector(15 downto 0);
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
    signal ex_output_EX_MEM: std_logic_vector(15 downto 0);  
    signal EPC : std_logic_vector(15 downto 0); 
    signal exception_sel : std_logic_vector(1 downto 0);
    signal branch_decision : std_logic;
    signal branch_pc: std_logic_vector(15 downto 0);

    signal muxOut: std_logic_vector(15 downto 0);

    signal mew_wb_read_out: std_logic;
    signal mew_wb_ex_output_out: std_logic_vector(15 downto 0);
    signal mew_wb_reg_out: std_logic;
    signal mew_wb_port_out: std_logic;
    signal mew_wb_pc_out: std_logic;
    signal mew_wb_rdst_out: std_logic_vector(2 downto 0);
    signal mew_wb_in_signal_out: std_logic;
    signal mew_wb_in_value_out: std_logic_vector(15 downto 0);
    signal mew_wb_mem_out: std_logic_vector(15 downto 0);

    signal stack_value_fetch_out: std_logic_vector(15 downto 0);

    signal ex_push_signal_in: std_logic;
    signal ex_push_signal_out: std_logic;

    signal stack_decode_immediate: std_logic;
    signal stack_op_decode_immediate: std_logic;
    signal reset_IF_ID: std_logic;
    signal sp_reset: std_logic;
    signal alu_src_immed: std_logic;

begin
    reset_decode_execute <= exception_sel(0) or exception_sel(1);
    reset_IF_ID <= call or ret_signal or ex_rti_signal_in or branch_decision or exception_sel(0) or exception_sel(1);
    instruction_stage_inst: Instruction_Stage port map (
        clk => clk,
        reset => reset_IF_ID,
        Src2 => rsrc2_out_wire,
        from_ports => reset,
        Call_Signal => call,
        Branch_PC => branch_pc,
        stack_value_fetch_in => stackpointer_value,
        stack_value_fetch_out => stack_value_fetch_out,
        Branch_Decision => branch_decision,
        Exception_Handling => exception_sel,
        RET_Signal => ret_signal,
        RTI_Signal => ex_rti_signal_in,
        WB_Date => muxOut,
        WB_PC => mew_wb_pc_out,
        alu_src => alu_src_immed,
        next_PC => pcIn,
        instruction => instruction
    );
    
    sp_reset <= (exception_sel(0) and (not exception_sel(1))) or reset;
    stack_pointer_inst: stack_pointer port map (
        clk => clk,
        reset => sp_reset,
        sp_operation => stack_op_decode_immediate,
        w_en => stack_decode_immediate,
        sp_value_decode => ex_sp_memory_value_in,
        sp_memory_out => stackpointer_value
    );

    decode_stage_inst: decode_stage port map (
        clk => clk,
        reset=> reset,
        write_enable_writeback => mew_wb_reg_out,
        write_address_writeback => mew_wb_rdst_out,
        write_data_writeback => muxOut,
        pcIn => pcIn,
        stack_immediate => stack_decode_immediate,
        stack_op_immediate => stack_op_decode_immediate,
        input_value => in_port,
        instruction => instruction,
        stackpointer_value => stackpointer_value,
        stack_value_fetch => stack_value_fetch_out,
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
        push_signal => ex_push_signal_in,
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
        rsrc2_out => rsrc2_toberemove,
        ret_signal => ret_signal,
        alu_src_immed => alu_src_immed
    );

    execute_stage_inst: execute_stage port map (
        clk => clk,
        stack_in => ex_stack_in,
        mem_read_in => ex_mem_read_in,
        mem_write_in => ex_mem_write_in,
        push_signal_in => ex_push_signal_in,
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
        immed_value => instruction,
        EX_MEM_WBReg => ex_wb_reg_out,
        MEM_WB_WBReg => mew_wb_reg_out,
        EX_MEM_Rdst => ex_rdst_out,
        MEM_WB_Rdst => mew_wb_rdst_out,
        EX_MEM_ex_output => ex_output_EX_MEM,
        MEM_WB_output => muxOut,
        stack_out => ex_stack_out,
        mem_read_out => ex_mem_read_out,
        mem_write_out => ex_mem_write_out,
        sp_op_out => ex_sp_op_out,
        wb_reg_out => ex_wb_reg_out,
        wb_port_out => ex_wb_port_out,
        wb_pc_out => ex_wb_pc_out,
        in_signal_out => ex_in_signal_out,
        push_signal_out => ex_push_signal_out,
        rdst_out => ex_rdst_out,
        sp_memory_value_out => ex_sp_memory_value_out,
        ex_output_out => ex_output_EX_MEM,
        in_value_out => ex_in_value_out,
        rsrc2_data_out => ex_rsrc2_data_out,
        pc_out => ex_pc_out,
        EPC => EPC,
        exception_sel => exception_sel,
        branch_decision => branch_decision,
        branch_pc => branch_pc,
        forwarded_rsrc2 => rsrc2_out_wire
    );

    memory_stage: memory port map (
        clk => clk,
        stackSignal => ex_stack_out,
        memRead_in => ex_mem_read_out,
        memRead_out => mew_wb_read_out,
        memWrite => ex_mem_write_out,
        SPOperation => ex_sp_op_out,
        SPMemoryValue => ex_sp_memory_value_out,
        ex_output_in => ex_output_EX_MEM,
        ex_output_out => mew_wb_ex_output_out,
        WBReg_in => ex_wb_reg_out,
        WBReg_out => mew_wb_reg_out,
        WBPort_in => ex_wb_port_out,
        WBPort_out => mew_wb_port_out,
        WBPC_in => ex_wb_pc_out,
        WBPC_out => mew_wb_pc_out,
        rDest_in => ex_rdst_out,
        rDest_out => mew_wb_rdst_out,
        inSig_in => ex_in_signal_out,
        inSig_out => mew_wb_in_signal_out,
        inVal_in => ex_in_value_out,
        inVal_out => mew_wb_in_value_out,
        rSrcData2 => ex_rsrc2_data_out,
        push_signal => ex_push_signal_out,
        PC => ex_pc_out,
        memOut => mew_wb_mem_out,
        enable => '1'
    );

    write_back_stage: WB port map (
        clk => clk,
        wbReg => mew_wb_reg_out,
        rDest => mew_wb_rdst_out,
        wbOutEn => mew_wb_port_out,
        wbPC => mew_wb_pc_out,
        inSig => mew_wb_in_signal_out,
        memRead => mew_wb_read_out,
        inVal => mew_wb_in_value_out,
        memOut => mew_wb_mem_out,
        ex_output => mew_wb_ex_output_out,
        muxOut => muxOut
    );
    
    
    process(clk)
    begin
        if falling_edge(clk) and mew_wb_port_out = '1' then
            out_port_reg <= muxOut;
        end if;
    end process;
    out_port <= out_port_reg;
end architecture;