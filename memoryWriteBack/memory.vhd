library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity memory is
    port (
        clk: in std_logic;
        stackSignal: in std_logic;
        memRead: in std_logic;
        memWrite: in std_logic;
        SPOperation: in std_logic;
        SPMemoryValue: in std_logic_vector(15 downto 0);
        output: in std_logic_vector(15 downto 0);
        WBReg: out std_logic_vector(15 downto 0);
        WBPort: out std_logic_vector(15 downto 0);
        WBPC: out std_logic_vector(15 downto 0);
        rDest: out std_logic_vector(2 downto 0);
        inSig: in std_logic;
        inVal: in std_logic_vector(15 downto 0);
        rSrcData2: in std_logic_vector(15 downto 0);
        PC: in std_logic_vector(15 downto 0);
        INTSign: in std_logic;
        memOut: out std_logic_vector(15 downto 0)
    );
end memory;

architecture Behavioral of memory is
    signal address: std_logic_vector(15 downto 0);
    signal data: std_logic_vector(15 downto 0);
    type ram_type is array(0 to 65535) of std_logic_vector(15 downto 0);
    signal dataMemory : ram_type := (others => (others => '0'));
begin
    -- Concurrent address and data assignment based on the selection signals
    with stackSignal select
        address <= output when '0',
                  SPMemoryValue when '1',
                  (others => '0') when others;

    with SPOperation select
        data <= rSrcData2 when '0',
               PC when '1',
               (others => '0') when others;

    -- Process to handle memory read and write operations
    process(clk)
    begin
        if rising_edge(clk) then
            -- Memory read operation
            if memRead = '1' then
                memOut <= dataMemory(to_integer(unsigned(address)));
            end if;

            -- Memory write operation
            if memWrite = '1' then
                dataMemory(to_integer(unsigned(address))) <= data;
            end if;
        end if;
    end process;

end Behavioral;
