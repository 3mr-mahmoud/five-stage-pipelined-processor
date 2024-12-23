library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity stack_pointer is
    Port (
        clk              : in  std_logic;         
        reset            : in  std_logic;  
        sp_operation     : in  std_logic;         
        w_en             : in  std_logic;         
        sp_value_decode  : in  std_logic_vector(15 downto 0);
        sp_memory_out    : out std_logic_vector(15 downto 0)
    );
end stack_pointer;

architecture Behavioral of stack_pointer is
    signal sp_current : unsigned(15 downto 0) := (others => '0');
    signal sp_next    : unsigned(15 downto 0);
begin

    -- Process to update the stack pointer on clock edge
    process(clk, reset)
    begin
        if reset = '1' then
            sp_current <= "0000111111111111"; -- Reset value
        elsif falling_edge(clk) then
            if w_en = '1' then
                sp_current <= sp_next;
            end if;
        end if;
    end process;

    -- Process to calculate the next stack pointer value
    process(sp_current, sp_operation, sp_value_decode)
    begin
        if sp_operation = '1' then
            sp_next <= sp_current + 1; -- Increment
        else
            sp_next <= sp_current - 1; -- Decrement
        end if;
    end process;

    -- Output assignment
    sp_memory_out <= std_logic_vector(sp_current);

end Behavioral;
