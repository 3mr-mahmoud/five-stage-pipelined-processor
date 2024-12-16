library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


ENTITY execute_register IS
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
END ENTITY execute_register;

ARCHITECTURE register_arch OF execute_register IS
BEGIN
    process(clk, reset)
    BEGIN
        IF reset = '1' THEN
            DataOut <= (OTHERS => '0');
        ELSIF clk'EVENT AND clk = '1' THEN
            IF enable = '1' THEN
                DataOut <= DataIn;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE register_arch;