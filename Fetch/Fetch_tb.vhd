LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Instruction_Stage_TB IS
END Instruction_Stage_TB;

ARCHITECTURE behavior OF Instruction_Stage_TB IS
    COMPONENT Instruction_Stage IS
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            Src2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            from_ports : IN STD_LOGIC;
            Call_Signal : IN STD_LOGIC;
            Branch_PC : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            Branch_Decision : IN STD_LOGIC;
            Exception_Handling : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            RET_Signal, RTI_Signal : IN STD_LOGIC;
            WB_Date : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            WB_PC : IN STD_LOGIC;
            alu_src : IN STD_LOGIC;
            next_PC : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL clk, reset, from_ports, Call_Signal, Branch_Decision, WB_PC, alu_src : STD_LOGIC := '0';
    SIGNAL RET_Signal, RTI_Signal : STD_LOGIC := '0';
    SIGNAL Src2, Branch_PC, WB_Date : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Exception_Handling : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL next_PC, instruction : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN
    clk_process : PROCESS
    BEGIN
        WHILE TRUE LOOP
            clk <= '0';
            WAIT FOR 10 ns;
            clk <= '1';
            WAIT FOR 10 ns;
        END LOOP;
    END PROCESS;

    uut : Instruction_Stage
    PORT MAP (
        clk => clk,
        reset => reset,
        Src2 => Src2,
        from_ports => from_ports,
        Call_Signal => Call_Signal,
        Branch_PC => Branch_PC,
        Branch_Decision => Branch_Decision,
        Exception_Handling => Exception_Handling,
        RET_Signal => RET_Signal,
        RTI_Signal => RTI_Signal,
        WB_Date => WB_Date,
        WB_PC => WB_PC,
        alu_src => alu_src,
        next_PC => next_PC,
        instruction => instruction
    );

    stimulus : PROCESS
    BEGIN
        -- Test cases
        reset <= '1';
        WAIT FOR 20 ns;
        reset <= '0';
        WAIT FOR 20000 ns;

        WAIT;
    END PROCESS;

END behavior;
