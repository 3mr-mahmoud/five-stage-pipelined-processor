LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Adder IS
    PORT (
        input1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        input2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        result : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END Adder;

ARCHITECTURE behavior OF Adder IS
BEGIN
    PROCESS (input1, input2)
    BEGIN
        result <= STD_LOGIC_VECTOR(unsigned(input1) + unsigned(input2));
    END PROCESS;
END behavior;