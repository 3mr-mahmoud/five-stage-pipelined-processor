library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WB_tb is
end WB_tb;

architecture Behavioral of WB_tb is
    -- Component declaration of the WB entity
    component WB is
        port (
            clk: in std_logic;
            wbReg: inout std_logic;
            rDest: inout std_logic_vector(2 downto 0);
            wbOutEn: inout std_logic;
            wbPC: inout std_logic;
            inSig: inout std_logic;
            memRead: inout std_logic;
            inVal: inout std_logic_vector(15 downto 0);
            memOut: inout std_logic_vector(15 downto 0);
            output: inout std_logic_vector(15 downto 0);
            muxOut: out std_logic_vector(15 downto 0)
        );
    end component;

    -- Signals for the testbench
    signal clk: std_logic := '0';
    signal wbReg: std_logic := '0';
    signal rDest: std_logic_vector(2 downto 0) := "000";
    signal wbOutEn: std_logic := '0';
    signal wbPC: std_logic := '0';
    signal inSig: std_logic := '0';
    signal memRead: std_logic := '0';
    signal inVal: std_logic_vector(15 downto 0) := "0000000000000000";
    signal memOut: std_logic_vector(15 downto 0) := "0000000000000001";
    signal output: std_logic_vector(15 downto 0) := "0000000000000010";
    signal muxOut: std_logic_vector(15 downto 0);

    -- Clock generation
    constant clk_period: time := 20 ns;
begin
    -- Clock process
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Instantiate the WB component
    uut: WB
        port map (
            clk => clk,
            wbReg => wbReg,
            rDest => rDest,
            wbOutEn => wbOutEn,
            wbPC => wbPC,
            inSig => inSig,
            memRead => memRead,
            inVal => inVal,
            memOut => memOut,
            output => output,
            muxOut => muxOut
        );

    -- Stimuli process to drive inputs
    stimulus: process
    begin
        -- Test case 1: inSig = '1', memRead = '0'
        inSig <= '1'; memRead <= '0'; inVal <= "1111000011110000"; memOut <= "0000000000000001"; output <= "1010101010101010";
        wait for 40 ns;  -- Wait for some time to observe muxOut

        -- Test case 2: inSig = '0', memRead = '1'
        inSig <= '0'; memRead <= '1'; inVal <= "1111000011110000"; memOut <= "0000000000000001"; output <= "1010101010101010";
        wait for 40 ns;

        -- Test case 3: inSig = '0', memRead = '0'
        inSig <= '0'; memRead <= '0'; inVal <= "1111000011110000"; memOut <= "0000000000000001"; output <= "1010101010101010";
        wait for 40 ns;

        -- Test case 4: inSig = '1', memRead = '1'
        inSig <= '1'; memRead <= '1'; inVal <= "1111000011110000"; memOut <= "0000000000000001"; output <= "1010101010101010";
        wait for 40 ns;

        -- End the simulation
        wait;
    end process;
end Behavioral;
