LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY my_DFF IS
    PORT (
        d : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        enable : IN STD_LOGIC;
        q : OUT STD_LOGIC
    );
END my_DFF;

ARCHITECTURE a_my_DFF OF my_DFF IS
BEGIN
    PROCESS (clk, rst)
    BEGIN
        IF (rst = '1') THEN
            q <= '0';
        ELSIF (clk'event AND clk = '1') THEN
            IF enable = '1' THEN
                q <= d;
            END IF;
        END IF;
    END PROCESS;
END a_my_DFF;