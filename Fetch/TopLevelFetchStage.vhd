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
        RET_Signal, RTI_Signal : IN STD_LOGIC;
        WB_Date : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        stack_value_fetch_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        stack_value_fetch_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
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
    SIGNAL fetched_instruction : STD_LOGIC_VECTOR(15 DOWNTO 0); -- Internal signal for fetched instruction
    SIGNAL mux1_sel : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    -- signal if_id_reset : std_logic := '0';

    COMPONENT Instruction_Memory
        PORT (
            PC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            enable : IN STD_LOGIC;
            instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            IM_0, IM_1, IM_2, IM_3, IM_4, IM_5, IM_6, IM_7 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT IF_ID_reg
        PORT (
            clk, reset, en : IN STD_LOGIC;

            next_pc_in, instruction_in, stack_value_fetch_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            next_pc_out, instruction_out, stack_value_fetch_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

BEGIN
    -- PC Increment Logic
    PC_plus_one <= STD_LOGIC_VECTOR(TO_UNSIGNED(TO_INTEGER(unsigned(current_PC)) + 1, 16));
    -- PC Register process (with reset)
    PROCESS (clk, reset)
    BEGIN
        -- IF reset = '1' THEN
        --     current_PC <= (OTHERS => '0'); -- Reset PC to 0
        -- ELSIF 
        IF rising_edge(clk) THEN
            IF PC_enable = '1' THEN
                current_PC <= next_PC_internal; -- Update the PC with next_PC_internal
            END IF;
        END IF;
    END PROCESS;

    -- ALU source control signals
    alu_src_14 <= alu_src AND fetched_instruction(14);
    alu_src_15 <= alu_src AND fetched_instruction(15);

    -- PC enable logic
    PC_enable <= (NOT (NOT alu_src AND fetched_instruction(14) AND fetched_instruction(15))) OR from_ports;

    -- MUX Chain Logic
    mux1_sel <= (alu_src_15 AND (NOT alu_src)) &
        (alu_src_14 AND (NOT alu_src));
    mux1_out <= PC_plus_one WHEN mux1_sel = "00" ELSE
        IM_7 WHEN mux1_sel = "10" ELSE
        IM_6 WHEN mux1_sel = "01" ELSE
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
        instruction => fetched_instruction, -- Store fetched instruction in internal signal
        IM_0 => IM_0,
        IM_1 => IM_1,
        IM_2 => IM_2,
        IM_3 => IM_3,
        IM_4 => IM_4,
        IM_5 => IM_5,
        IM_6 => IM_6,
        IM_7 => IM_7
    );

    -- if_id_reset <= Branch_Decision OR Call_Signal OR RET_Signal OR RTI_Signal or Exception_Handling(0) OR Exception_Handling(1);
    -- if_id_reset <= Call_Signal;

    -- IF_ID Register instance
    U_IF_ID : IF_ID_reg
    PORT MAP(
        clk => clk,
        reset => reset, -- Reset when branch, call, return, or exception
        en => '1', -- Always enabled
        next_pc_in => PC_plus_one, -- Assign next_PC_internal to next_pc_in
        instruction_in => fetched_instruction, -- Assign fetched_instruction to instruction_in
        next_pc_out => next_PC, -- Assign next_PC value to output
        stack_value_fetch_in => stack_value_fetch_in, -- Assign stack_value_fetch_in to output
        stack_value_fetch_out => stack_value_fetch_out, -- Assign stack_value_fetch_out to output
        instruction_out => instruction -- Assign the fetched instruction to output
    );
    -- instruction <= fetched_instruction; -- Assign the fetched instruction to output
    -- next_PC <= PC_plus_one; -- Assign next_PC value to output

END behavior;