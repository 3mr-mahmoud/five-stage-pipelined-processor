library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity flags_register_tb is
end flags_register_tb;

architecture Behavioral of flags_register_tb is
    -- Component Declaration for the Unit Under Test (UUT)
    component flags_register
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
    end component;
    
    -- Inputs
    signal clk           : STD_LOGIC := '0';
    signal write_enable  : STD_LOGIC := '0';
    signal int_signal    : STD_LOGIC := '0';
    signal rti_signal    : STD_LOGIC := '0';
    signal input_Z       : STD_LOGIC := '0';
    signal input_C       : STD_LOGIC := '0';
    signal input_N       : STD_LOGIC := '0';
    
    -- Outputs
    signal zero_flag     : STD_LOGIC;
    signal carry_flag    : STD_LOGIC;
    signal negative_flag : STD_LOGIC;
    
    -- Clock period definition
    constant CLK_PERIOD : time := 20 ps;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: flags_register PORT MAP (
        clk => clk,
        write_enable => write_enable,
        int_signal => int_signal,
        rti_signal => rti_signal,
        input_Z => input_Z,
        input_C => input_C,
        input_N => input_N,
        zero_flag => zero_flag,
        carry_flag => carry_flag,
        negative_flag => negative_flag
    );

    -- Clock process
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initial reset and wait
        write_enable <= '0';
        int_signal <= '0';
        rti_signal <= '0';
        input_Z <= '0';
        input_C <= '0';
        input_N <= '0';
        wait for CLK_PERIOD;
        
        -- Test normal flag writing
        write_enable <= '1';
        input_Z <= '1';
        input_C <= '1';
        input_N <= '0';
        wait for CLK_PERIOD;
        
        -- Verify flag values
        assert zero_flag = '1' 
            report "Zero flag not set correctly" 
            severity failure;
        assert carry_flag = '1' 
            report "Carry flag not set correctly" 
            severity failure;
        assert negative_flag = '0' 
            report "Negative flag not set correctly" 
            severity failure;
        
        -- Test interrupt signal
        write_enable <= '0';
        rti_signal <= '0';
        int_signal <= '1';
        wait for CLK_PERIOD*2;
        
        -- Change flags to ensure temporary storage works
        input_Z <= '0';
        input_C <= '0';
        input_N <= '1';
        rti_signal <= '0';
        int_signal <= '0';
        write_enable <= '1';
        wait for CLK_PERIOD;
        
        -- Test return from interrupt
        int_signal <= '0';
        write_enable <= '0';
        rti_signal <= '1';
        wait for CLK_PERIOD;
        
        -- Verify flags are restored
        assert zero_flag = '1' 
            report "Zero flag not restored correctly" 
            severity failure;
        assert carry_flag = '1' 
            report "Carry flag not restored correctly" 
            severity failure;
        assert negative_flag = '0' 
            report "Negative flag not restored correctly" 
            severity failure;
        
        -- Finish simulation
        report "Simulation completed successfully";
        wait;
    end process;
end Behavioral;