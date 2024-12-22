LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY control_unit IS
    PORT (
        opcode : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        operand2_selector : OUT STD_LOGIC;
        alu_src_execute : IN STD_LOGIC;
        alu_src : OUT STD_LOGIC;
        branch_signal : OUT STD_LOGIC;
        branch_code : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        alu_enable : OUT STD_LOGIC;
        alu_function : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        set_carry_signal : OUT STD_LOGIC;
        stack_signal : OUT STD_LOGIC;
        stack_operation : OUT STD_LOGIC;
        memory_read : OUT STD_LOGIC;
        memory_write : OUT STD_LOGIC;
        writeback_register : OUT STD_LOGIC;
        writeback_port : OUT STD_LOGIC;
        writeback_pc : OUT STD_LOGIC;
        input_signal : OUT STD_LOGIC;
        ret_signal : OUT STD_LOGIC;
        rti_signal : OUT STD_LOGIC;
        int_signal : OUT STD_LOGIC;
        call_signal : OUT STD_LOGIC
    );
END ENTITY control_unit;

ARCHITECTURE control_arch OF control_unit IS
BEGIN
    PROCESS (opcode, alu_src_execute)
    BEGIN
        IF alu_src_execute = '0' THEN
            -- Handle operand2_selector
            CASE opcode IS
                WHEN "0000010" | "0000100" | "0000110" | "0000111" |
                    "0001100" | "0001110" | "0010010" =>
                    operand2_selector <= '1';
                WHEN OTHERS =>
                    operand2_selector <= '0';
            END CASE;

            -- Handle alu_src based on opcode(6 downto 2)
            CASE opcode(6 DOWNTO 2) IS
                WHEN "00010" =>
                    alu_src <= '1';
                WHEN OTHERS =>
                    alu_src <= '0';
            END CASE;

            -- Handle branch_signal
            CASE opcode IS
                WHEN "0001110" | "0010011" | "0010100" | "0010101" | "0010110" =>
                    branch_signal <= '1';
                WHEN OTHERS =>
                    branch_signal <= '0';
            END CASE;

            -- Handle branch_code
            CASE opcode IS
                WHEN "0010011" => branch_code <= "01"; -- JZ
                WHEN "0010100" => branch_code <= "10"; -- JN
                WHEN "0010101" => branch_code <= "11"; -- JC
                WHEN OTHERS => branch_code <= "00";
            END CASE;

            -- Handle alu_enable
            CASE opcode IS
                WHEN "0000011" | "0000101" | "0000100" | "0000110" |
                    "0001001" | "0001010" | "0001000" | "0000111" =>
                    alu_enable <= '1';
                WHEN OTHERS =>
                    alu_enable <= '0';
            END CASE;

            -- Handle alu_function
            CASE opcode IS
                WHEN "0000011" => alu_function <= "000"; -- NOT
                WHEN "0000101" => alu_function <= "001"; -- INC
                WHEN "0000100" => alu_function <= "010"; -- AND
                WHEN "0000110" | "0001001" | "0001000" | "0001010" =>
                    alu_function <= "011"; -- ADD and variants
                WHEN "0000111" => alu_function <= "100"; -- SUB
                WHEN OTHERS => alu_function <= "000";
            END CASE;

            -- Handle set_carry_signal
            CASE opcode IS
                WHEN "0000001" => set_carry_signal <= '1';
                WHEN OTHERS => set_carry_signal <= '0';
            END CASE;

            -- Handle stack_signal
            CASE opcode IS
                WHEN "0001100" | "0001101" | "0001110" | "0001111" |
                    "0010000" | "0100000" | "1000000" =>
                    stack_signal <= '1';
                WHEN OTHERS =>
                    stack_signal <= '0';
            END CASE;

            -- Handle stack_operation
            CASE opcode IS
                WHEN "0001101" | "0001111" | "0010000" =>
                    stack_operation <= '1';
                WHEN OTHERS =>
                    stack_operation <= '0';
            END CASE;

            -- Handle memory_read
            CASE opcode IS
                WHEN "0001101" | "0001001" | "0001111" | "0010000" =>
                    memory_read <= '1';
                WHEN OTHERS =>
                    memory_read <= '0';
            END CASE;

            -- Handle memory_write
            CASE opcode IS
                WHEN "0001100" | "0001010" | "0001110" | "0100000" | "1000000" =>
                    memory_write <= '1';
                WHEN OTHERS =>
                    memory_write <= '0';
            END CASE;

            -- Handle writeback_register
            CASE opcode IS
                WHEN "0000010" | "0000011" | "0000100" | "0000101" |
                    "0000110" | "0000111" | "0001000" | "0001001" |
                    "0001011" | "0001101" | "0010001" =>
                    writeback_register <= '1';
                WHEN OTHERS =>
                    writeback_register <= '0';
            END CASE;

            -- Handle writeback_port
            CASE opcode IS
                WHEN "0010010" => writeback_port <= '1';
                WHEN OTHERS => writeback_port <= '0';
            END CASE;

            -- Handle writeback_pc
            CASE opcode IS
                WHEN "0001111" | "0010000" => writeback_pc <= '1';
                WHEN OTHERS => writeback_pc <= '0';
            END CASE;

            -- Handle input_signal
            CASE opcode IS
                WHEN "0010001" => input_signal <= '1';
                WHEN OTHERS => input_signal <= '0';
            END CASE;

            -- Handle ret_signal
            CASE opcode IS
                WHEN "0001111" => ret_signal <= '1';
                WHEN OTHERS => ret_signal <= '0';
            END CASE;

            -- Handle rti_signal
            CASE opcode IS
                WHEN "0010000" => rti_signal <= '1';
                WHEN OTHERS => rti_signal <= '0';
            END CASE;

            -- Handle int_signal
            CASE opcode IS
                WHEN "0100000" | "1000000" => int_signal <= '1';
                WHEN OTHERS => int_signal <= '0';
            END CASE;

            -- Handle call_signal
            CASE opcode IS
                WHEN "0001110" => call_signal <= '1';
                WHEN OTHERS => call_signal <= '0';
            END CASE;

        ELSE
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
        END IF;
    END PROCESS;
END ARCHITECTURE control_arch;