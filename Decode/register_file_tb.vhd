LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY register_file_tb IS
END ENTITY register_file_tb;

ARCHITECTURE behavior OF register_file_tb IS

    -- Component declaration for the Unit Under Test (UUT)
    COMPONENT register_file IS
        PORT (
            clk: IN STD_LOGIC;
            write_enable: IN STD_LOGIC;
            write_data: IN std_logic_vector(15 downto 0);
            write_address: IN std_logic_vector(2 downto 0);
            read_address1: IN std_logic_vector(2 downto 0);
            read_address2: IN std_logic_vector(2 downto 0);
            read_data1: OUT std_logic_vector(15 downto 0);
            read_data2: OUT std_logic_vector(15 downto 0)
        );
    END COMPONENT;

    -- Signals for connecting to the UUT
    SIGNAL clk: STD_LOGIC := '0';
    SIGNAL write_enable: STD_LOGIC := '0';
    SIGNAL write_data: std_logic_vector(15 downto 0) := (others => '0');
    SIGNAL write_address: std_logic_vector(2 downto 0) := (others => '0');
    SIGNAL read_address1: std_logic_vector(2 downto 0) := (others => '0');
    SIGNAL read_address2: std_logic_vector(2 downto 0) := (others => '0');
    SIGNAL read_data1: std_logic_vector(15 downto 0);
    SIGNAL read_data2: std_logic_vector(15 downto 0);

    -- Clock period definition
    CONSTANT clk_period: TIME := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: register_file PORT MAP (
        clk => clk,
        write_enable => write_enable,
        write_data => write_data,
        write_address => write_address,
        read_address1 => read_address1,
        read_address2 => read_address2,
        read_data1 => read_data1,
        read_data2 => read_data2
    );

    -- Clock generation process
    clk_process: PROCESS
    BEGIN
        WHILE TRUE LOOP
            clk <= '1';
            WAIT FOR clk_period / 2;
            clk <= '0';
            WAIT FOR clk_period / 2;
        END LOOP;
    END PROCESS;

    -- Stimulus process
    stimulus_process: PROCESS
    BEGIN
        -- Test case 1: Write to address 0 and read back
        write_enable <= '1';
        write_address <= "000"; -- Address 0
        write_data <= x"1234"; -- Data to write
        WAIT FOR clk_period;
        write_enable <= '0';

        -- Read from address 0
        read_address1 <= "000";
        WAIT FOR clk_period;
        ASSERT read_data1 = x"1234" REPORT "Test case 1 failed: Address 0 read mismatch" SEVERITY ERROR;

        -- Test case 2: Write to address 1 and read back
        write_enable <= '1';
        write_address <= "001"; -- Address 1
        write_data <= x"5678"; -- Data to write
        WAIT FOR clk_period;
        write_enable <= '0';

        -- Read from address 1
        read_address1 <= "001";
        WAIT FOR clk_period;
        ASSERT read_data1 = x"5678" REPORT "Test case 2 failed: Address 1 read mismatch" SEVERITY ERROR;

        -- Test case 3: Simultaneous reads
        read_address1 <= "000"; -- Read from address 0
        read_address2 <= "001"; -- Read from address 1
        WAIT FOR clk_period;
        ASSERT read_data1 = x"1234" AND read_data2 = x"5678" REPORT "Test case 3 failed: Simultaneous read mismatch" SEVERITY ERROR;

        -- Finish simulation
        WAIT;
    END PROCESS;

END ARCHITECTURE behavior;
