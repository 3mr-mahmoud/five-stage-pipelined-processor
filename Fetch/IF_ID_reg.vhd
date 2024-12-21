LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY IF_ID_reg IS
    PORT (
        clk, reset, en : IN STD_LOGIC;
        -- Input signals
        next_pc_in, instruction_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        -- Output signals
        next_pc_out, instruction_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END ENTITY IF_ID_reg;

ARCHITECTURE IF_ID_reg_architecture OF IF_ID_reg IS
    -- Internal signals
    SIGNAL next_pc, instruction : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
    next_pc_out <= next_pc;
    instruction_out <= instruction;

    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            next_pc <= (OTHERS => '0');
            instruction <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF en = '1' THEN
                next_pc <= next_pc_in;
                instruction <= instruction_in;
            END IF;
        END IF;

    END PROCESS;
END ARCHITECTURE IF_ID_reg_architecture;