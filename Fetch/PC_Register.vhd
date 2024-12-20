LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY PC_Register IS
    PORT (
        clk : IN STD_LOGIC;
        enable : IN STD_LOGIC;
        PC_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- 16-bit input to the PC
        PC_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) -- 16-bit output from the PC
    );
END PC_Register;

ARCHITECTURE behavior OF PC_Register IS
    SIGNAL PC_bits : STD_LOGIC_VECTOR(15 DOWNTO 0); -- Signal to store PC bits

    COMPONENT my_DFF
        PORT (
            d : IN STD_LOGIC;
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            enable : IN STD_LOGIC;
            q : OUT STD_LOGIC
        );
    END COMPONENT;

BEGIN
    -- Instantiate 16 D flip-flops (1-bit registers) to create a 16-bit PC register
    -- Each bit of the PC register is stored in a separate D flip-flop
    gen_PC_register : FOR i IN 0 TO 15 GENERATE
        U1 : my_DFF
        PORT MAP(
            d => PC_in(i),
            clk => clk,
            rst => '0',
            enable => enable,
            q => PC_bits(i)
        );
    END GENERATE;

    -- Output the 16-bit PC value
    PC_out <= PC_bits;

END behavior;