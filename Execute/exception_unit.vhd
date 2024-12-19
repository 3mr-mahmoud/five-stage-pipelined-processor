library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY exception_unit IS
    PORT (
        memory_read, memory_write, stack_signal: IN std_logic;
        SP_value, ex_output, PC: IN std_logic_vector(15 downto 0);
        exception_sel: OUT std_logic_vector(1 downto 0);
        exception_PC: OUT std_logic_vector(15 downto 0)
    );
END ENTITY exception_unit;

ARCHITECTURE exception_arch OF exception_unit IS
    CONSTANT THRESHOLD : unsigned(15 downto 0) := to_unsigned(4095, 16);
BEGIN
    process(memory_read, memory_write, stack_signal, SP_value, ex_output, PC)
    begin
        if stack_signal = '1' then
            if unsigned(SP_value) > THRESHOLD then
                exception_sel <= "01";
                exception_PC <= PC;
            else 
                exception_sel <= "00";
                exception_PC <= (others => '0');
            end if;
        elsif memory_read = '1' or memory_write = '1' then
            if unsigned(ex_output) > THRESHOLD then
                exception_sel <= "10";
                exception_PC <= PC;
            else
                exception_sel <= "00";
                exception_PC <= (others => '0');
            end if;
        else
            exception_sel <= "00";
            exception_PC <= (others => '0');
        end if;
    end process;
END ARCHITECTURE exception_arch;
