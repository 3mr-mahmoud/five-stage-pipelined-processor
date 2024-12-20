LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Instruction_Memory IS
    PORT (
        PC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        enable : IN STD_LOGIC;
        instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        IM_0 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        IM_1 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        IM_2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        IM_3 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        IM_4 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        IM_5 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        IM_6 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        IM_7 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END Instruction_Memory;

ARCHITECTURE behavior OF Instruction_Memory IS
    SIGNAL address : INTEGER RANGE 0 TO 65535;
    TYPE ram_type IS ARRAY (0 TO 65535) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL dataMemory : ram_type := (OTHERS => (OTHERS => '0'));
BEGIN

    IM_0 <= dataMemory(65528);
    IM_1 <= dataMemory(65529);
    IM_2 <= dataMemory(65530);
    IM_3 <= dataMemory(65531);
    IM_4 <= dataMemory(65532);
    IM_5 <= dataMemory(65533);
    IM_6 <= dataMemory(65534);
    IM_7 <= dataMemory(65535);

    -- Combinatorial process for instruction fetch
    PROCESS (PC, enable)
    BEGIN
        IF enable = '1' THEN
            address <= to_integer(unsigned(PC));
            instruction <= dataMemory(address);
        END IF;
    END PROCESS;

END behavior;