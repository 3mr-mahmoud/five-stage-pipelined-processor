library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY ALU_unit_tb IS
END ENTITY ALU_unit_tb;

ARCHITECTURE testbench OF ALU_unit_tb IS

    -- Constants
    constant WIDTH : integer := 16;

    -- Signals for ALU inputs
    signal reset : std_logic := '0';
    signal enable : std_logic := '0';
    signal ALU_func : std_logic_vector(2 downto 0) := (others => '0');
    signal branch_code : std_logic_vector(1 downto 0) := (others => '0');
    signal A, B : std_logic_vector(WIDTH-1 downto 0) := (others => '0');

    -- Signals for ALU outputs
    signal ALU_output : std_logic_vector(WIDTH-1 downto 0);
    signal flags : std_logic_vector(2 downto 0);  -- Carry, Negative, Zero

BEGIN

    -- Instantiate the ALU_unit
    uut: ENTITY work.ALU_unit
        GENERIC MAP (
            WIDTH => WIDTH
        )
        PORT MAP (
            reset => reset,
            enable => enable,
            ALU_func => ALU_func,
            branch_code => branch_code,
            A => A,
            B => B,
            ALU_output => ALU_output,
            flags => flags
        );

    -- Test process
    stimulus: process
    begin
        -- Test 1: NOT operation
        enable <= '1';
        ALU_func <= "000"; -- NOT
        A <= x"AAAA"; -- Input A
        B <= (others => '0'); -- B not used for NOT operation
        wait for 50 ps;

        -- Test 2: Increment operation
        ALU_func <= "001"; -- Increment
        A <= x"0001";
        wait for 50 ps;

        -- Test 3: AND operation
        ALU_func <= "010"; -- AND
        A <= x"FF00";
        B <= x"00FF";
        wait for 50 ps;

        ALU_func <= "000";
        enable <= '0';
        wait for 50 ps;

        -- Test 4: Addition
        ALU_func <= "011"; -- Addition
        enable <= '1';
        A <= x"0001";
        B <= x"0001";
        wait for 50 ps;

        -- Test 5: Subtraction
        ALU_func <= "100"; -- Subtraction
        A <= x"0002";
        B <= x"0001";
        wait for 50 ps;

        -- Test 6: Subtraction with Carry
        ALU_func <= "100";
        A <= x"0001";
        B <= x"0002";
        wait for 50 ps;

        -- Test 7: Default case (invalid operation)
        ALU_func <= "101"; -- Unused operation code
        A <= x"1234";
        B <= x"5678";
        wait for 50 ps;

        -- Disable ALU
        enable <= '0';
        wait for 50 ps;

        -- Finish simulation
        wait;
    end process;

END ARCHITECTURE testbench;