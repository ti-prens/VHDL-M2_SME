--anenometre_avalon
library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


--*********************************************
-- liaision de l'anemometre a l'avalon
--**********************************************


entity anemometre_avalon is

    PORT(clk : in std_logic;
        in_freq_anemometre : in  std_logic;
        reset_n            : in  std_logic;
        address            : in  STD_LOGIC;
        writedata          : in  STD_LOGIC_VECTOR(31 downto 0);
        readdata           : out STD_LOGIC_VECTOR(31 downto 0);
        write_n            : in  std_logic;
        chipselect         : in  std_logic
    --data_anemometre    : out STD_LOGIC_VECTOR(7 downto 0) := (others => '0')
    );

end anemometre_avalon;






architecture anemometre_avalon_oc of anemometre_avalon is
    --------------------------------------------------------------------------------
    -- on declare les variables de l'architecture avant le premier begin
    --------------------------------------------------------------------------------

    signal S_continu         : std_logic                    := '0';
    signal S_start_stop      : std_logic                    := '0';
    signal S_data_anemometre : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');


    signal S_internal_reset : std_logic;
    signal S_data_valid     : std_logic;


    --------------------------------------------------------------------------------
    -- declaration des composants
    --------------------------------------------------------------------------------

    component anemometre is
        port (
            clk_50M            : in     STD_LOGIC;
            in_freq_anemometre : in     std_logic;
            reset_n            : in     std_logic;
            continu            : in     std_logic;
            start_stop         : in     std_logic;
            data_valid         : out    std_logic;
            data_anemometre    : buffer STD_LOGIC_VECTOR(7 downto 0) := (others => '0')
        );
    end component anemometre;



    --------------------------------------------------------------------------------
    -- description de l'architecture
    --------------------------------------------------------------------------------

begin

    anemometre_1 : anemometre
        port map (
            clk_50M            => clk,
            in_freq_anemometre => in_freq_anemometre,
            reset_n            => S_internal_reset,
            continu            => S_continu,
            start_stop         => S_start_stop,
            data_valid         => S_data_valid,
            data_anemometre    => S_data_anemometre
        );



    pWrite : process(clk,reset_n)
    begin
        if(reset_n = '0') then -- reset sur reset_n == 0
            S_internal_reset <= '0';
            S_start_stop       <= '0';
            S_continu          <= '0';

        elsif rising_edge(clk) then

            if(chipselect = '1' and write_n = '0') then

                if(address = '0') then
                    S_internal_reset <= writedata(0);
                    S_continu        <= writedata(1);
                    S_start_stop     <= writedata(2);
                end if;

            end if;
        end if;
    end process pWrite;


    --Output
    readdata <= X"00000" & "000" & S_data_valid & S_data_anemometre; --32bit


end anemometre_avalon_oc;