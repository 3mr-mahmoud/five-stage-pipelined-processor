LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY register_file IS 
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
END ENTITY register_file;


ARCHITECTURE register_file_arch OF register_file IS
    TYPE register_array IS ARRAY (0 TO 7) OF std_logic_vector(15 DOWNTO 0);
    SIGNAL registers: register_array;
BEGIN
    PROCESS(clk)
    BEGIN
        IF clk'EVENT AND clk = '0' THEN
            IF write_enable = '1' THEN
                registers(to_integer(unsigned(write_address))) <= write_data;
            END IF;
        END IF;
    END PROCESS;

    read_data1 <= registers(to_integer(unsigned(read_address1)));
    read_data2 <= registers(to_integer(unsigned(read_address2)));
END ARCHITECTURE register_file_arch;
