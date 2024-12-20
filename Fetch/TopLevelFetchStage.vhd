LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Instruction_Stage IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC; -- Reset input
        Src2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        from_ports : IN STD_LOGIC;
        Call_Signal : IN STD_LOGIC;
        Branch_PC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        Branch_Decision : IN STD_LOGIC;
        Exception_Handling : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        WB_Date : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        WB_PC : IN STD_LOGIC;
        alu_src : IN STD_LOGIC;
        next_PC : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END Instruction_Stage;

ARCHITECTURE behavior OF Instruction_Stage IS
    -- Internal signals
    SIGNAL IM_0, IM_1, IM_2, IM_3, IM_4, IM_5, IM_6, IM_7 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL mux1_out, mux2_out, mux3_out, mux4_out, mux5_out, mux6_out : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL current_PC : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0'); -- Initialize to 0
    SIGNAL next_PC_internal : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL PC_enable : STD_LOGIC;
    SIGNAL alu_src_14, alu_src_15 : STD_LOGIC;
    SIGNAL PC_plus_one : STD_LOGIC_VECTOR(15 DOWNTO 0);

    COMPONENT Instruction_Memory
        PORT (
            PC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            enable : IN STD_LOGIC;
            instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            IM_0, IM_1, IM_2, IM_3, IM_4, IM_5, IM_6, IM_7 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

BEGIN
    -- PC Increment Logic
    PC_plus_one <= STD_LOGIC_VECTOR(TO_UNSIGNED(TO_INTEGER(unsigned(current_PC)) + 1, 16));

    -- PC Register process (with reset)
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            current_PC <= (OTHERS => '0'); -- Reset PC to 0
        ELSIF rising_edge(clk) THEN
            IF PC_enable = '1' THEN
                current_PC <= next_PC_internal; -- Update the PC with next_PC_internal
            END IF;
        END IF;
    END PROCESS;

    -- ALU source control signals
    alu_src_14 <= alu_src AND IM_0(14);
    alu_src_15 <= alu_src AND IM_0(15);

    -- PC enable logic
    PC_enable <= (NOT (alu_src AND IM_0(14) AND IM_0(15))) OR from_ports;

    -- MUX Chain Logic
    mux1_out <= PC_plus_one WHEN reset = '0' AND alu_src_15 = '0' AND alu_src_14 = '0' ELSE
        IM_7 WHEN alu_src_15 = '1' ELSE
        IM_6 WHEN alu_src_14 = '1' ELSE
        PC_plus_one;

    mux2_out <= Src2 WHEN Call_Signal = '1' ELSE
        mux1_out;
    mux3_out <= Branch_PC WHEN Branch_Decision = '1' ELSE
        mux2_out;
    mux4_out <= IM_3 WHEN Exception_Handling = "10" ELSE
        IM_2 WHEN Exception_Handling = "01" ELSE
        mux3_out;
    mux5_out <= WB_Date WHEN WB_PC = '1' ELSE
        mux4_out;
    mux6_out <= IM_0 WHEN from_ports = '1' ELSE
        mux5_out;

    -- Next PC Calculation
    next_PC_internal <= mux6_out;

    -- Instruction Memory instance
    U_IM : Instruction_Memory
    PORT MAP(
        PC => current_PC, -- Use current PC for instruction fetch
        enable => '1', -- Always enabled
        instruction => instruction, -- Directly assign the instruction
        IM_0 => IM_0,
        IM_1 => IM_1,
        IM_2 => IM_2,
        IM_3 => IM_3,
        IM_4 => IM_4,
        IM_5 => IM_5,
        IM_6 => IM_6,
        IM_7 => IM_7
    );

    -- Outputs
    next_PC <= next_PC_internal; -- Output the next PC value
END behavior;