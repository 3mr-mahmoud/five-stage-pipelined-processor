LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY forward_unit IS
    PORT (
        EX_MEM_Rdst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        MEM_WB_Rdst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        ID_EX_Rsrc1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        ID_EX_Rsrc2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        EX_MEM_WBReg : IN STD_LOGIC;
        MEM_WB_WBReg : IN STD_LOGIC;
        EX_MEM_IN_signal : IN STD_LOGIC;
        ForwardA : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        ForwardB : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
END forward_unit;

ARCHITECTURE forward_arch OF forward_unit IS
BEGIN
    PROCESS (EX_MEM_Rdst, MEM_WB_Rdst, ID_EX_Rsrc1, ID_EX_Rsrc2, EX_MEM_WBReg, MEM_WB_WBReg)
    BEGIN

        IF (EX_MEM_IN_signal = '1' AND EX_MEM_Rdst = ID_EX_Rsrc1) THEN
            ForwardA <= "11";
        ELSIF (EX_MEM_WBReg = '1' AND EX_MEM_Rdst = ID_EX_Rsrc1) THEN
            ForwardA <= "01";
        ELSIF (MEM_WB_WBReg = '1' AND MEM_WB_Rdst = ID_EX_Rsrc1) THEN
            ForwardA <= "10";
        ELSE
            ForwardA <= "00";
        END IF;

        IF (EX_MEM_IN_signal = '1' AND EX_MEM_Rdst = ID_EX_Rsrc2) THEN
            ForwardB <= "11";
        ELSIF (EX_MEM_WBReg = '1' AND EX_MEM_Rdst = ID_EX_Rsrc2) THEN
            ForwardB <= "01";
        ELSIF (MEM_WB_WBReg = '1' AND MEM_WB_Rdst = ID_EX_Rsrc2) THEN
            ForwardB <= "10";
        ELSE
            ForwardB <= "00";
        END IF;

    END PROCESS;
END forward_arch;