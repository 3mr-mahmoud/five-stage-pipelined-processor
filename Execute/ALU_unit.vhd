library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY ALU_unit IS
    GENERIC(
        WIDTH: INTEGER := 16
    );
    PORT (
        enable: IN std_logic;
        ALU_func: IN std_logic_vector(2 downto 0);
        A, B: IN std_logic_vector(WIDTH-1 downto 0);
        ALU_output: OUT std_logic_vector(WIDTH-1 downto 0);
        flags: OUT std_logic_vector(2 downto 0) -- Order: carry, negative, zero
    );
END ENTITY ALU_unit;

ARCHITECTURE ALU_arch OF ALU_unit IS
BEGIN
    -- Process for ALU operations
    process(enable, ALU_func, A, B)
    VARIABLE result: std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    begin
        if enable = '1' then
            CASE ALU_func IS
                WHEN "000" => -- NOT operation
                    result := not A;
                    flags(2) <= '0';
                WHEN "001" => -- Increment (no change in carry)
                    result := std_logic_vector(unsigned(A) + 1);
                    flags(2) <= '0';
                WHEN "010" => -- AND operation
                    result := A AND B;
                    flags(2) <= '0';
                WHEN "011" => -- Addition
                    result := std_logic_vector(unsigned(A) + unsigned(B));
                    if unsigned(A) + unsigned(B) > 2**WIDTH - 1 then
                        flags(2) <= '1';
                    else
                        flags(2) <= '0';
                    end if;
                WHEN "100" => -- Subtraction
                    result := std_logic_vector(unsigned(A) - unsigned(B));
                    if unsigned(A) < unsigned(B) then
                        flags(2) <= '1';
                    else
                        flags(2) <= '0';
                    end if;
                WHEN OTHERS => -- Default case
                    result := (others => '0');
                    flags(2) <= '0';
            END CASE;
            flags(1) <= result(WIDTH-1);
            if unsigned(result) = 0 then
                flags(0) <= '1';
            else
                flags(0) <= '0';
            end if;
        else
            result := result;
        end if;
        ALU_output <= result;
    end process;

END ARCHITECTURE ALU_arch;