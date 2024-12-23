library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
    port (
        clk: in std_logic;
        stackSignal: in std_logic;
        memRead_in: in std_logic;
        memRead_out: out std_logic;
        memWrite: in std_logic;
        SPOperation: in std_logic;
        SPMemoryValue: in std_logic_vector(15 downto 0);
        ex_output_in: in std_logic_vector(15 downto 0);
        ex_output_out: out std_logic_vector(15 downto 0);
        WBReg_in: in std_logic;
        WBReg_out: out std_logic;
        WBPort_in: in std_logic;
        WBPort_out: out std_logic;
        WBPC_in: in std_logic;
        WBPC_out: out std_logic;
        rDest_in: in std_logic_vector(2 downto 0);
        rDest_out: out std_logic_vector(2 downto 0);
        inSig_in: in std_logic;
        inSig_out: out std_logic;
        inVal_in: in std_logic_vector(15 downto 0);
        inVal_out: out std_logic_vector(15 downto 0);
        rSrcData2: in std_logic_vector(15 downto 0);
        PC: in std_logic_vector(15 downto 0);
        memOut: out std_logic_vector(15 downto 0);
        enable: in std_logic;
        push_signal: in std_logic
    );
end memory;

architecture Behavioral of memory is
    signal address: std_logic_vector(15 downto 0);
    signal data: std_logic_vector(15 downto 0);
    type ram_type is array(0 to 65535) of std_logic_vector(15 downto 0);
    signal dataMemory : ram_type := (others => (others => '0'));

    signal memRead_reg: std_logic;
    signal ex_output_reg: std_logic_vector(15 downto 0);
    signal WBPort_reg: std_logic;
    signal WBReg_reg: std_logic;
    signal WBPC_reg: std_logic;
    signal rDest_reg: std_logic_vector(2 downto 0);
    signal inSig_reg: std_logic;
    signal inVal_reg: std_logic_vector(15 downto 0);
begin

    -- Drive the output ports with the internal signals
    memRead_out <= memRead_reg;
    ex_output_out <= ex_output_reg;
    WBPort_out <= WBPort_reg;
    WBReg_out <= WBReg_reg;
    WBPC_out <= WBPC_reg;
    rDest_out <= rDest_reg;
    inSig_out <= inSig_reg;
    inVal_out <= inVal_reg;

    -- Concurrent address and data assignment based on the selection signals
    with stackSignal select
        address <= ex_output_in when '0',
                  SPMemoryValue when '1',
                  (others => '0') when others;

    -- Process to handle memory read and write operations
    process(clk, enable, SPOperation, stackSignal, push_signal)
    begin
        if (SPOperation = '0' and push_signal = '0') and stackSignal = '1' then
            data <= PC;
        else
            data <= rSrcData2;
        end if;

        if rising_edge(clk) and enable = '1' then

            memRead_reg <= memRead_in;
            ex_output_reg <= ex_output_in;
            WBPort_reg <= WBPort_in;
            WBReg_reg <= WBReg_in;
            WBPC_reg <= WBPC_in;
            rDest_reg <= rDest_in;
            inSig_reg <= inSig_in;
            inVal_reg <= inVal_in;

            -- Memory read operation
            if memRead_in = '1' then
                memOut <= dataMemory(to_integer(unsigned(address)));
            end if;

            -- Memory write operation
            if memWrite = '1' then
                dataMemory(to_integer(unsigned(address))) <= data;
            end if;

        end if;
    end process;

end Behavioral;
