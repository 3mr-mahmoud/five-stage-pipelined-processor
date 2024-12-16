library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity forward_unit is
    port (
        EX_MEM_Rdst  : in  std_logic_vector(4 downto 0);
        MEM_WB_Rdst  : in  std_logic_vector(4 downto 0);
        ID_EX_Rsrc1   : in  std_logic_vector(4 downto 0);
        ID_EX_Rsrc2   : in  std_logic_vector(4 downto 0);
        EX_MEM_WBReg : in  std_logic;
        MEM_WB_WBReg : in  std_logic;
        alu_src       : in std_logic;
        ForwardA      : out std_logic_vector(1 downto 0);
        ForwardB      : out std_logic_vector(1 downto 0)
    );
end forward_unit;

architecture forward_arch of forward_unit is
begin
    process(EX_MEM_Rdst, MEM_WB_Rdst, ID_EX_Rsrc1, ID_EX_Rsrc2, EX_MEM_WBReg, MEM_WB_WBReg)
    begin
        ForwardA <= "00";
        ForwardB <= "00";
        if(EX_MEM_WBReg = '1' and EX_MEM_Rdst = ID_EX_Rsrc1) then
            ForwardA <= "01";
        elsif (MEM_WB_WBReg = '1' and MEM_WB_Rdst = ID_EX_Rsrc1) then
            ForwardA <= "10";
        end if;

        if alu_src = '1' then
            ForwardB <= "11";
        else 
            if(EX_MEM_WBReg = '1' and EX_MEM_Rdst = ID_EX_Rsrc2) then
                ForwardB <= "01";
            elsif (MEM_WB_WBReg = '1' and MEM_WB_Rdst = ID_EX_Rsrc2) then
                ForwardB <= "10";
            end if;
        end if;
    end process;
end forward_arch;