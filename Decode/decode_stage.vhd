library IEEE;
use IEEE.std_logic_1164.all;


ENTITY decode_stage IS
PORT (
    clk: IN std_logic;
    write_enable_writeback: IN std_logic;
    write_address_writeback: IN std_logic_vector(2 downto 0);
    write_data_writeback: IN std_logic_vector(15 downto 0);
    pcIn: IN std_logic_vector(15 downto 0);
    stack_value_fetch: IN std_logic_vector(15 downto 0);
    input_value: IN std_logic_vector(15 downto 0);
    instruction: IN std_logic_vector(15 downto 0);
    stackpointer_value: IN std_logic_vector(15 downto 0);
    reset_decode_execute: IN std_logic;
    enable_decode_execute: IN std_logic;
    stack_immediate: OUT std_logic;
    stack_op_immediate: OUT std_logic;
    -- Output signals
    stack, mem_read, mem_write, sp_op, alu_enable, wb_reg,
    wb_port, wb_pc, in_signal, branch_signal, alu_src, 
    rti_signal, int_signal, carry : out std_logic;
    alu_function : out std_logic_vector(2 downto 0);
    branch_code : out std_logic_vector(1 downto 0);
    rsrc1, rsrc2, rdst : out std_logic_vector(2 downto 0);
    sp_memory_value, rsrc1_data, rsrc2_data, in_value, pc : out std_logic_vector(15 downto 0);
    call_signal: out std_logic;
    push_signal: out std_logic;

    rsrc2_out: out std_logic_vector(15 downto 0);
    ret_signal: out std_logic
);
END ENTITY decode_stage;


architecture decode_arch of decode_stage is 
    signal opcode: std_logic_vector(6 downto 0);
    signal operand2_selector_wire: std_logic;
    signal alu_src_execute_wire: std_logic;
    signal branch_signal_wire: std_logic;
    signal branch_code_wire: std_logic_vector(1 downto 0);
    signal alu_src_wire: std_logic;
    signal alu_enable_wire: std_logic;
    signal alu_function_wire: std_logic_vector(2 downto 0);
    signal set_carry_signal_wire: std_logic;
    signal stack_signal_wire: std_logic;
    signal stack_operation_wire: std_logic;
    signal memory_read_wire: std_logic;
    signal memory_write_wire: std_logic;
    signal writeback_register_wire: std_logic;
    signal writeback_port_wire: std_logic;
    signal writeback_pc_wire: std_logic;
    signal input_signal_wire: std_logic;
    signal rti_signal_wire: std_logic;
    signal int_signal_wire: std_logic;
    signal call_signal_wire: std_logic;
    signal push_signal_wire: std_logic;
    signal Rsrc1_wire: std_logic_vector(2 downto 0);
    signal Rdst_wire: std_logic_vector(2 downto 0);
    signal Rsrc2_wire: std_logic_vector(2 downto 0);
    signal read_address2_wire: std_logic_vector(2 downto 0);

    signal rsrc1_out_wire: std_logic_vector(15 downto 0);
    signal rsrc2_out_wire: std_logic_vector(15 downto 0);

    component control_unit
    PORT (
        opcode: IN std_logic_vector(6 downto 0);
        operand2_selector: OUT std_logic;
        alu_src_execute: IN std_logic;
        alu_src: OUT std_logic;
        branch_signal: OUT std_logic;
        branch_code: OUT std_logic_vector(1 downto 0);
        alu_enable: OUT std_logic;
        alu_function: OUT std_logic_vector(2 downto 0);
        set_carry_signal: OUT std_logic;
        stack_signal: OUT std_logic;
        stack_operation: OUT std_logic;
        memory_read: OUT std_logic;
        memory_write: OUT std_logic;
        writeback_register: OUT std_logic;
        writeback_port: OUT std_logic;
        writeback_pc: OUT std_logic;
        input_signal: OUT std_logic;
        ret_signal: OUT std_logic;
        rti_signal: OUT std_logic;
        int_signal: OUT std_logic;
        call_signal: OUT std_logic;
        push_signal: OUT std_logic
    );
    end component;



    component operand_mux
    PORT (
        Rdst: IN std_logic_vector(2 downto 0);
        Rsrc2: IN std_logic_vector(2 downto 0);
        operand2_selector: IN std_logic;
        result: OUT std_logic_vector(2 downto 0)
    );
    end component;

    component register_file
    PORT (
        clk: IN STD_LOGIC;
        write_enable: IN STD_LOGIC;
        write_data: IN std_logic_vector(15 downto 0);
        write_address: IN std_logic_vector(2 downto 0);
        read_address1: IN std_logic_vector(2 downto 0);
        read_address2: IN std_logic_vector(2 downto 0);
        read_data1: OUT std_logic_vector(15 downto 0);
        read_data2: OUT std_logic_vector(15 downto 0)
    );
    end component;

    component ID_EX_REGISTER
     PORT (
        clk, reset, en : in std_logic;
        stack_in, mem_read_in, mem_write_in, sp_op_in, alu_enable_in, wb_reg_in,
        wb_port_in, wb_pc_in, in_signal_in, branch_signal_in, alu_src_in, 
        rti_signal_in, int_signal_in, carry_in, call_signal_in, push_signal_in, ret_signal_in : in std_logic;
        alu_function_in : in std_logic_vector(2 downto 0);
        branch_code_in : in std_logic_vector(1 downto 0);
        rsrc1_in, rsrc2_in, rdst_in : in std_logic_vector(2 downto 0);
        sp_memory_value_in, rsrc1_data_in, rsrc2_data_in, in_value_in, pc_in : in std_logic_vector(15 downto 0);
        stack_out, mem_read_out, mem_write_out, sp_op_out, alu_enable_out, wb_reg_out,
        wb_port_out, wb_pc_out, in_signal_out, branch_signal_out, alu_src_out, 
        rti_signal_out, int_signal_out, carry_out, call_signal_out, push_signal_out, ret_signal_out : out std_logic;
        alu_function_out : out std_logic_vector(2 downto 0);
        branch_code_out : out std_logic_vector(1 downto 0);
        rsrc1_out, rsrc2_out, rdst_out : out std_logic_vector(2 downto 0);
        sp_memory_value_out, rsrc1_data_out, rsrc2_data_out, in_value_out, pc_out : out std_logic_vector(15 downto 0)
     );
    end component;

    signal stackpointer_value_memory: std_logic_vector(15 downto 0);
    signal ret_signal_wire: std_logic;
begin
    opcode <= instruction(15 downto 9);

    control_unit_inst: control_unit PORT MAP (
        opcode => opcode,
        operand2_selector => operand2_selector_wire,
        alu_src_execute => alu_src_execute_wire,
        alu_src => alu_src_wire,
        branch_signal => branch_signal_wire,
        branch_code => branch_code_wire,
        alu_enable => alu_enable_wire,
        alu_function => alu_function_wire,
        set_carry_signal => set_carry_signal_wire,
        stack_signal => stack_signal_wire,
        stack_operation => stack_operation_wire,
        memory_read => memory_read_wire,
        memory_write => memory_write_wire,
        writeback_register => writeback_register_wire,
        writeback_port => writeback_port_wire,
        writeback_pc => writeback_pc_wire,
        input_signal => input_signal_wire,
        ret_signal => ret_signal_wire,
        rti_signal => rti_signal_wire,
        int_signal => int_signal_wire,
        call_signal => call_signal_wire,
        push_signal => push_signal_wire
    );

    stack_immediate <= stack_signal_wire;
    stack_op_immediate <= stack_operation_wire;

    Rdst_wire <= instruction(8 downto 6);
    Rsrc2_wire <= instruction(2 downto 0);

    operand_mux_inst: operand_mux PORT MAP (
        Rdst => Rdst_wire,
        Rsrc2 => Rsrc2_wire,
        operand2_selector => operand2_selector_wire,
        result => read_address2_wire
    );

    Rsrc1_wire <= instruction(5 downto 3);

    register_file_inst: register_file PORT MAP (
        clk => clk,
        write_enable => write_enable_writeback,
        write_data => write_data_writeback,
        write_address => write_address_writeback,
        read_address1 => Rsrc1_wire,
        read_address2 => read_address2_wire,
        read_data1 => rsrc1_out_wire,
        read_data2 => rsrc2_out_wire
    );

    alu_src <= alu_src_execute_wire;


    with stack_operation_wire select
        stackpointer_value_memory <= stackpointer_value when '1',
                                     stack_value_fetch when others;

    ID_EX_REGISTER_inst: ID_EX_REGISTER PORT MAP (
        clk => clk,
        reset => reset_decode_execute,
        en => enable_decode_execute,
        stack_in => stack_signal_wire,
        mem_read_in => memory_read_wire,
        call_signal_in => call_signal_wire,
        push_signal_in => push_signal_wire,
        ret_signal_in => ret_signal_wire,
        mem_write_in => memory_write_wire,
        sp_op_in => stack_operation_wire,
        alu_enable_in => alu_enable_wire,
        wb_reg_in => writeback_register_wire,
        wb_port_in => writeback_port_wire,
        wb_pc_in => writeback_pc_wire,
        in_signal_in => input_signal_wire,
        branch_signal_in => branch_signal_wire,
        alu_src_in => alu_src_wire,
        rti_signal_in => rti_signal_wire,
        int_signal_in => int_signal_wire,
        carry_in => set_carry_signal_wire,
        alu_function_in => alu_function_wire,
        branch_code_in => branch_code_wire,
        rsrc1_in => Rsrc1_wire,
        rsrc2_in => read_address2_wire,
        rdst_in => Rdst_wire,
        sp_memory_value_in => stackpointer_value_memory,
        rsrc1_data_in => rsrc1_out_wire,
        rsrc2_data_in => rsrc2_out_wire,
        in_value_in => input_value,
        pc_in => pcIn,
        stack_out => stack,
        mem_read_out => mem_read,
        mem_write_out => mem_write,
        sp_op_out => sp_op,
        alu_enable_out => alu_enable,
        wb_reg_out => wb_reg,
        wb_port_out => wb_port,
        wb_pc_out => wb_pc,
        in_signal_out => in_signal,
        branch_signal_out => branch_signal,
        alu_src_out => alu_src_execute_wire,
        rti_signal_out => rti_signal,
        int_signal_out => int_signal,
        carry_out => carry,
        alu_function_out => alu_function,
        branch_code_out => branch_code,
        rsrc1_out => rsrc1,
        rsrc2_out => rsrc2,
        rdst_out => rdst,
        call_signal_out => call_signal,
        push_signal_out => push_signal,
        sp_memory_value_out => sp_memory_value,
        rsrc1_data_out => rsrc1_data,
        rsrc2_data_out => rsrc2_data,
        in_value_out =>  in_value,
        pc_out => pc,
        ret_signal_out => ret_signal
    );
    rsrc2_out <= rsrc2_out_wire;

end architecture decode_arch;