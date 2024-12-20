library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity stack_pointer is
    Port (
        clk           : in  std_logic;         
        reset         : in  std_logic;  
        sp_operation  : in  std_logic;         
        w_en          : in  std_logic;         
        sp_value_decode   : in  std_logic_vector(15 downto 0);
        sp_memory_out : out std_logic_vector(15 downto 0)
    );
end stack_pointer;

architecture Behavioral of stack_pointer is
    signal sp_current : std_logic_vector(15 downto 0);
    signal sp_next    : std_logic_vector(15 downto 0);
begin

    process(clk, reset)
    begin
        if reset = '1' then
            sp_current <= "0000111111111111";
        elsif rising_edge(clk) then
            if w_en = '1' then
                sp_current <= sp_next;
            end if;
        end if;
    end process;

    process(sp_current, sp_operation)
    begin
        if sp_operation = '1' then
            sp_next <= sp_value_decode + 1;
        else
            sp_next <= sp_value_decode - 1;
        end if;
    end process;

    process(sp_operation, sp_current, sp_value_decode)
    begin
        if sp_operation = '1' then
            sp_memory_out <= sp_value_decode;
        else
            sp_memory_out <= sp_current;
        end if;
    end process;

end Behavioral;
