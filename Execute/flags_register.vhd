library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity flags_register is
    Port ( clk           : in STD_LOGIC;
           write_enable   : in STD_LOGIC;  
           int_signal     : in STD_LOGIC;  
           rti_signal     : in STD_LOGIC; 
           input_Z        : in STD_LOGIC;
           input_C        : in STD_LOGIC;
           input_N        : in STD_LOGIC;
           zero_flag      : out STD_LOGIC;
           carry_flag     : out STD_LOGIC;
           negative_flag  : out STD_LOGIC);
end flags_register;

architecture Behavioral of flags_register is
    -- Internal signals for flags
    signal reg_Z : STD_LOGIC := '0';
    signal reg_C : STD_LOGIC := '0';
    signal reg_N : STD_LOGIC := '0';

    -- Temporary storage for flags
    signal temp_Z : STD_LOGIC := '0';
    signal temp_C : STD_LOGIC := '0';
    signal temp_N : STD_LOGIC := '0';
begin
    -- Assign internal signals to output ports
    zero_flag <= reg_Z;
    carry_flag <= reg_C;
    negative_flag <= reg_N;

    -- Unified process for flag management
    process (clk)
    begin
        if rising_edge(clk) then
            -- Prioritize interrupt and return from interrupt signals
            if rti_signal = '1' then
                -- Restore flags from temporary storage
                reg_Z <= temp_Z;
                reg_C <= temp_C;
                reg_N <= temp_N;
            elsif int_signal = '1' then
                -- Store current flags to temporary storage
                temp_Z <= reg_Z;
                temp_C <= reg_C;
                temp_N <= reg_N;
            elsif write_enable = '1' then
                -- Update flags with new input values
                reg_Z <= input_Z;
                reg_C <= input_C;
                reg_N <= input_N;
            end if;
        end if;
    end process;
end Behavioral;