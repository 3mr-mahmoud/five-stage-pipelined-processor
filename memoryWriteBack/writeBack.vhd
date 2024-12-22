library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 


entity WB is
    port (
        clk: in std_logic;
        wbReg: in std_logic;
        rDest: in std_logic_vector(2 downto 0);
        wbOutEn: in std_logic;
        wbPC: in std_logic;
        

        inSig: in std_logic;
        memRead: in std_logic;

        inVal: in std_logic_vector(15 downto 0);
        memOut: in std_logic_vector(15 downto 0);
        ex_output: in std_logic_vector(15 downto 0);

        muxOut: out std_logic_vector(15 downto 0)
    );
end WB;

ARCHITECTURE Behavioral OF WB IS
signal muxSel : std_logic_vector(1 downto 0);
BEGIN
    muxSel <= inSig & memRead;
    WITH (muxSel) SELECT
        muxOut <= inVal     WHEN "10",
                  memOut    WHEN "01",
                  ex_output WHEN "00",
                  (OTHERS => '0') WHEN OTHERS;
END Behavioral;