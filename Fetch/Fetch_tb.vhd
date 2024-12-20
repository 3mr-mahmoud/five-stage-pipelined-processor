LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Instruction_Stage_TB IS
END Instruction_Stage_TB;

ARCHITECTURE behavior OF Instruction_Stage_TB IS
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT Instruction_Stage
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
    END COMPONENT;

    -- Signal Declarations for the testbench
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL reset : STD_LOGIC := '0'; -- Reset signal
    SIGNAL Src2 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL from_ports : STD_LOGIC := '0';
    SIGNAL Call_Signal : STD_LOGIC := '0';
    SIGNAL Branch_PC : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Branch_Decision : STD_LOGIC := '0';
    SIGNAL Exception_Handling : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL WB_Date : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL WB_PC : STD_LOGIC := '0';
    SIGNAL alu_src : STD_LOGIC := '0';
    SIGNAL next_PC : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL instruction : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN
    -- Clock Generation Process
    clk_process : PROCESS
    BEGIN
        WHILE TRUE LOOP
            clk <= '1';
            WAIT FOR 10 ps;
            clk <= '0';
            WAIT FOR 10 ps;
        END LOOP;
    END PROCESS;

    -- Instantiate the Unit Under Test (UUT)
    uut : Instruction_Stage
    PORT MAP(
        clk => clk,
        reset => reset, -- Connect the reset signal
        Src2 => Src2,
        from_ports => from_ports,
        Call_Signal => Call_Signal,
        Branch_PC => Branch_PC,
        Branch_Decision => Branch_Decision,
        Exception_Handling => Exception_Handling,
        WB_Date => WB_Date,
        WB_PC => WB_PC,
        alu_src => alu_src,
        next_PC => next_PC,
        instruction => instruction
    );

    -- Test Stimulus Process
    stimulus : PROCESS
    BEGIN

        reset <= '0'; -- Release reset
        WAIT FOR 20 ps;

        -- Test Case 2: Test with default values
        Src2 <= "0000000000000000";
        Branch_PC <= "0000000000000000";
        Branch_Decision <= '0';
        Exception_Handling <= "00";
        WB_Date <= "0000000000000000";
        WB_PC <= '0';
        alu_src <= '0';
        WAIT FOR 40 ps; -- Increased clock cycles for this test case
        WAIT;
    END PROCESS;

END behavior;