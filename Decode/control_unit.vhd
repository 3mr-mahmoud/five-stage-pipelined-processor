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
            -- Handle operand2_selector
            case opcode is
                when "0000010" | "0000100" | "0000110" | "0000111" | 
                     "0001010" | "0001100" | "0001110" | "0010010" =>
                    operand2_selector <= '1';
                when others =>
                    operand2_selector <= '0';
            end case;

            -- Handle alu_src based on opcode(6 downto 2)
            case opcode(6 downto 2) is
                when "00010" =>
                    alu_src <= '1';
                when others =>
                    alu_src <= '0';
            end case;

            -- Handle branch_signal
            case opcode is
                when "0001110" | "0010011" | "0010100" | "0010101" | "0010110" =>
                    branch_signal <= '1';
                when others =>
                    branch_signal <= '0';
            end case;

            -- Handle branch_code
            case opcode is
                when "0010011" => branch_code <= "01";  -- JZ
                when "0010100" => branch_code <= "10";  -- JN
                when "0010101" => branch_code <= "11";  -- JC
                when others => branch_code <= "00";
            end case;

            -- Handle alu_enable
            case opcode is
                when "0000011" | "0000101" | "0000100" | "0000110" |
                     "0001001" | "0001010" | "0001000" | "0000111" =>
                    alu_enable <= '1';
                when others =>
                    alu_enable <= '0';
            end case;

            -- Handle alu_function
            case opcode is
                when "0000011" => alu_function <= "000";  -- NOT
                when "0000101" => alu_function <= "001";  -- INC
                when "0000100" => alu_function <= "010";  -- AND
                when "0000110" | "0001001" | "0001000" | "0001010" =>
                    alu_function <= "011";  -- ADD and variants
                when "0000111" => alu_function <= "100";  -- SUB
                when others => alu_function <= "000";
            end case;

            -- Handle set_carry_signal
            case opcode is
                when "0000001" => set_carry_signal <= '1';
                when others => set_carry_signal <= '0';
            end case;

            -- Handle stack_signal
            case opcode is
                when "0001100" | "0001101" | "0001110" | "0001111" |
                     "0010000" | "0100000" | "1000000" =>
                    stack_signal <= '1';
                when others =>
                    stack_signal <= '0';
            end case;

            -- Handle stack_operation
            case opcode is
                when "0001101" | "0001111" | "0010000" =>
                    stack_operation <= '1';
                when others =>
                    stack_operation <= '0';
            end case;

            -- Handle memory_read
            case opcode is
                when "0001101" | "0001001" | "0001111" | "0010000" =>
                    memory_read <= '1';
                when others =>
                    memory_read <= '0';
            end case;

            -- Handle memory_write
            case opcode is
                when "0001100" | "0001010" | "0001110" | "0100000" | "1000000" =>
                    memory_write <= '1';
                when others =>
                    memory_write <= '0';
            end case;

            -- Handle writeback_register
            case opcode is
                when "0000010" | "0000011" | "0000100" | "0000101" |
                     "0000110" | "0000111" | "0001000" | "0001001" |
                     "0001011" | "0001101" | "0010001" =>
                    writeback_register <= '1';
                when others =>
                    writeback_register <= '0';
            end case;

            -- Handle writeback_port
            case opcode is
                when "0010010" => writeback_port <= '1';
                when others => writeback_port <= '0';
            end case;

            -- Handle writeback_pc
            case opcode is
                when "0001111" | "0010000" => writeback_pc <= '1';
                when others => writeback_pc <= '0';
            end case;

            -- Handle input_signal
            case opcode is
                when "0010001" => input_signal <= '1';
                when others => input_signal <= '0';
            end case;

            -- Handle ret_signal
            case opcode is
                when "0001111" => ret_signal <= '1';
                when others => ret_signal <= '0';
            end case;

            -- Handle rti_signal
            case opcode is
                when "0010000" => rti_signal <= '1';
                when others => rti_signal <= '0';
            end case;

            -- Handle int_signal
            case opcode is
                when "0100000" | "1000000" => int_signal <= '1';
                when others => int_signal <= '0';
            end case;

            -- Handle call_signal
            case opcode is
                when "0001110" => call_signal <= '1';
                when others => call_signal <= '0';
            end case;

        else
            -- Default values when alu_src_execute = '1'
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