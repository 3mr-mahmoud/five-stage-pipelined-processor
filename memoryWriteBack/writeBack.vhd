library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 


entity WB is
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
        ex_output: inout std_logic_vector(15 downto 0);

        muxOut: out std_logic_vector(15 downto 0)
    );
end WB;

architecture Behavioral of WB is
    begin
        process(clk)
            variable muxSel: std_logic_vector(1 downto 0);
        begin
            if rising_edge(clk) then
                muxSel := inSig & memRead;
    
                case muxSel is
                    when "10" =>
                        muxOut <= inVal;
                    when "01" =>
                        muxOut <= memOut;
                    when "00" =>
                        muxOut <= ex_output;
                    when others =>
                        muxOut <= (others => '0');
                end case;
            end if;
        end process;
    end Behavioral;