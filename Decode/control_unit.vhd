library IEEE;
use IEEE.std_logic_1164.all;

ENTITY control_unit IS
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
    call_signal: OUT std_logic
);
END ENTITY control_unit;


ARCHITECTURE control_arch OF control_unit IS
BEGIN

    process(opcode, alu_src_execute)
    BEGIN

    if alu_src_execute = '0' then 
        -- 0 => Rdst, 1 => Rsrc2 
        with opcode select
            operand2_selector <=
                '1' when "0000010" |    -- MOV Rdst, Rsrc2
                        "0000100" |    -- AND Rdst, Rsrc1, Rsrc2
                        "0000110" |    -- ADD Rdst, Rsrc1, Rsrc2
                        "0000111" |    -- SUB Rdst, Rsrc1, Rsrc2
                        "0001010" |    -- STD Rsrc2, offset(Rsrc1)
                        "0001100" |    -- PUSH Rsrc2
                        "0001110" |    -- CALL Rsrc2
                        "0010010",     -- OUT Rsrc2
                '0' when others;

        -- 0 => no immediate value , 1 => use immediate value 
        -- with opcode select
        --     alu_src <=
        --         '1' when "0001000" |    -- IADD Rdst, Rsrc1, Imm
        --                  "0001001" |    -- LDD Rdst, offset(Rsrc1)
        --                  "0001010" |    -- STD Rsrc2, offset(Rsrc1)
        --                  "0001011",     -- LDM Rdst, Imm
        --         '0' when others;

        -- 0 => no immediate value , 1 => use immediate value 
        with opcode(6 downto 2) select
            alu_src <=
                '1' when "00010",
                '0' when others;


        with opcode select
            branch_signal <=
                '1' when "0001110" |    -- CALL Rsrc2
                        "0010011" |    -- JZ Rsrc1
                        "0010100" |    -- JN Rsrc1
                        "0010101" |    -- JC Rsrc1
                        "0010110",    -- JMP Rsrc1
                '0' when others;

        with opcode select
            branch_code <=
                "01" when "0010011", -- JZ Rsrc1
                "10" when "0010100", -- JN Rsrc1
                "11" when "0010101", -- JC Rsrc1
                "00" when others;


        with opcode select
            alu_enable <=
                '1' when "0000011" |    -- NOT
                        "0000101" |     -- INC
                        "0000100" |     -- AND
                        "0000110" |     -- ADD
                        "0001001" |     -- LDD Rdst, offset(Rsrc1)   
                        "0001010" |     -- STD Rsrc2, offset(Rsrc1)
                        "0001000" |     -- IADD Rdst, Rsrc1, Imm
                        "0000111",      -- SUB
                '0' when others;

        with opcode select
            alu_function <=
                "000" when "0000011",    -- NOT
                "001" when "0000101",    -- INC 
                "010" when "0000100",    -- AND

                "011" when "0000110" |  -- ADD
                        "0001001" |  -- LDD Rdst, offset(Rsrc1)        
                        "0001000" |  -- IADD Rdst, Rsrc1, Imm        
                        "0001010",  -- STD Rsrc2, offset(Rsrc1)
                "100" when "0000111",    -- SUB
                "000" when others;

        with opcode select
            set_carry_signal <=
                '1' when "0000001",
                '0' when others;


        with opcode select
            stack_signal <=
                '1' when "0001100"|  -- PUSH Rsrc2
                        "0001101"|  -- POP Rdst
                        "0001110"|  -- CALL 
                        "0001111"|  -- RET
                        "0010000"|  -- RTI
                        "0100000"|  -- INT 0
                        "1000000",  -- INT 2
                '0' when others;

        with opcode select
            stack_operation <=
                '1' when "0001101"|  -- POP Rdst
                        "0001111"|  -- RET
                        "0010000",  -- RTI
                '0' when others;


        with opcode select
            memory_read <=
                '1' when "0001101"|  -- POP Rdst
                        "0001001"|  -- LDD Rdst, offset(Rsrc1)
                        "0001111"|  -- RET
                        "0010000",  -- RTI
                '0' when others;


        with opcode select
            memory_write <=
                '1' when "0001100"|  -- PUSH Rsrc2
                        "0001010"|    -- STD Rsrc2, offset(Rsrc1)
                        "0001110"|  -- CALL 
                        "0100000"|  -- INT 0
                        "1000000",  -- INT 2
                '0' when others;


        with opcode select
            writeback_register <=
                '1' when "0000010"|  -- MOV Rdst, Rsrc2
                        "0000011"|    -- NOT Rdst, Rsrc1
                        "0000100"|  -- AND Rdst, Rsrc1, Rsrc2
                        "0000101"|  -- INC Rdst, Rsrc1
                        "0000110"|  -- ADD Rdst, Rsrc1, Rsrc2
                        "0000111"|  -- SUB Rdst, Rsrc1, Rsrc2
                        "0001000"|  -- IADD Rdst, Rsrc1, Imm
                        "0001001"|  -- LDD Rdst, offset(Rsrc1)
                        "0001011"|  -- LDM Rdst, Imm
                        "0001101"|  -- POP Rdst
                        "0010001",  -- IN Rdst
                '0' when others;

        with opcode select
            writeback_port <=
                '1' when "0010010", -- OUT Rsrc2
                '0' when others;

        with opcode select
            writeback_pc <=
                '1' when "0001111"|  -- RET
                        "0010000",  -- RTI
                '0' when others;

        with opcode select
            writeback_pc <=
                '1' when "0001111"|  -- RET
                        "0010000",  -- RTI
                '0' when others;

        with opcode select
            input_signal <=
                '1' when "0010001", -- IN Rdst
                '0' when others;

        with opcode select
            ret_signal <=
                '1' when "0001111", -- RET
                '0' when others;

        with opcode select
            rti_signal <=
                '1' when "0010000", -- RTI
                '0' when others;

        with opcode select
            int_signal <=
                '1' when "0100000"|  -- INT 0
                        "1000000",  -- INT 2
                '0' when others;
        
        with opcode select 
            call_signal <=
                '1' when "0001110", -- CALL Rsrc2
                '0' when others;

    else

        operand2_selector <= '0';
        alu_src <= '0';
        branch_signal <= '0';
        branch_code <= "00";
        alu_function <= "000";
        set_carry_signal <= '0';
        alu_enable <= '0';
        stack_signal <= '0';
        stack_operation <= '0';
        memory_read <= '0';
        memory_write <= '0';
        writeback_register <= '0';
        writeback_port <= '0';
        writeback_pc <= '0';
        input_signal <= '0';
        ret_signal <= '0';
        rti_signal <= '0';
        int_signal <= '0';
        call_signal <= '0';

    end if;


    end process;
END ARCHITECTURE control_arch;