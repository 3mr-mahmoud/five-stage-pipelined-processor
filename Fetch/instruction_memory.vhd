LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_textio.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;
USE std.textio.ALL;

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
    SIGNAL seed_memory : STD_LOGIC := '1';
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
    PROCESS (PC, enable,address, dataMemory, seed_memory)
        FILE insturcions_file : text;
        VARIABLE file_line : line;
        VARIABLE temp_data : STD_LOGIC_VECTOR(15 DOWNTO 0);
    BEGIN
        IF enable = '1' THEN
            address <= to_integer(unsigned(PC));
            instruction <= dataMemory(to_integer(unsigned(PC)));
        end if;
        if seed_memory = '1' then
            file_open(insturcions_file, "input.txt",  read_mode);
            FOR i IN dataMemory'RANGE LOOP
                IF NOT endfile(insturcions_file) THEN
                    readline(insturcions_file, file_line);
                    read(file_line, temp_data);
                    dataMemory(i) <= temp_data;
                END IF;
            END LOOP;
            seed_memory <= '0';
        END IF;
    END PROCESS;

END behavior;