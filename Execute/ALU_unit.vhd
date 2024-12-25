LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ALU_unit IS
    GENERIC (
        WIDTH : INTEGER := 16
    );
    PORT (
        reset : IN STD_LOGIC;
        enable : IN STD_LOGIC;
        branch_code : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        ALU_func : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        A, B : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        ALU_output : OUT STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0);
        flags : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) -- Order: carry, negative, zero
    );
END ENTITY ALU_unit;

ARCHITECTURE ALU_arch OF ALU_unit IS
BEGIN
    -- Process for ALU operations
    PROCESS (reset, enable, branch_code, ALU_func, A, B)
        VARIABLE result : STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
    BEGIN
        IF reset = '1' THEN
            result := (OTHERS => '0');
            if branch_code = "01" then
                flags(0) <= '0';
            elsif branch_code = "10" then
                flags(1) <= '0';
            elsif branch_code = "11" then
                flags(2) <= '0';
            end if;
        ELSIF enable = '1' THEN
            CASE ALU_func IS
                WHEN "000" => -- NOT operation
                    result := NOT A;
                    flags(2) <= '0';
                WHEN "001" => -- Increment
                    result := STD_LOGIC_VECTOR(unsigned(A) + 1);
                    IF unsigned(A) = 2**WIDTH - 1 THEN
                        flags(2) <= '1';
                    ELSE
                        flags(2) <= '0';
                    END IF;
                WHEN "010" => -- AND operation
                    result := A AND B;
                    flags(2) <= '0';
                WHEN "011" => -- Addition
                    result := STD_LOGIC_VECTOR(unsigned(A) + unsigned(B));
                    IF unsigned(A) + unsigned(B) > 2 ** WIDTH - 1 THEN
                        flags(2) <= '1';
                    ELSE
                        flags(2) <= '0';
                    END IF;
                WHEN "100" => -- Subtraction
                    result := STD_LOGIC_VECTOR(unsigned(A) - unsigned(B));
                    IF unsigned(A) < unsigned(B) THEN
                        flags(2) <= '1';
                    ELSE
                        flags(2) <= '0';
                    END IF;
                WHEN OTHERS => -- Default case
                    result := (OTHERS => '0');
                    flags(2) <= '0';
            END CASE;
            flags(1) <= result(WIDTH - 1);
            IF unsigned(result) = 0 THEN
                flags(0) <= '1';
            ELSE
                flags(0) <= '0';
            END IF;
        ELSE
            result := result;
        END IF;
        ALU_output <= result;
    END PROCESS;

END ARCHITECTURE ALU_arch;