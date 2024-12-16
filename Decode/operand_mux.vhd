library IEEE;
use IEEE.std_logic_1164.all;

ENTITY operand_mux IS
PORT (
    Rdst: IN std_logic_vector(2 downto 0);
    Rsrc2: IN std_logic_vector(2 downto 0);
    operand2_selector: IN std_logic;
    result: OUT std_logic_vector(2 downto 0)
);
END ENTITY operand_mux;

ARCHITECTURE operand_mux_arch OF operand_mux IS
BEGIN

    with operand2_selector select
        result <=
            Rsrc2 when '1',
            Rdst when others;

END ARCHITECTURE operand_mux_arch;