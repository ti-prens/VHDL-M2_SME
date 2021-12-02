library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity TbBoutons is
--no inputs and outputs
end entity TbBoutons;

architecture rtl of TbBoutons is
    constant CLK_PER          : time := 20 ns;
    signal Clk                : std_logic;
    signal SRst               : std_logic;
    signal BP_Babord: in std_logic;
	signal BP_Tribord : in std_logic;
	signal BP_STBY  : in std_logic;  
    

begin

    pClk : process
    begin
        Clk <= '1';
        wait for CLK_PER / 2;
        Clk <= '0';
        wait for CLK_PER / 2;
    end process pClk;

    pRst : process
    begin
        SRst <= '0';
        wait for 30 ns;
        SRst <= '1';
        wait ; 
    end process pRst;

    pAnemo : process 
    begin
        in_freq_anemometre <= '0';
        wait for 10*CLK_PER;
        for i in 0 to 200 loop
             in_freq_anemometre <= '0';
             wait for 20*CLK_PER;
             in_freq_anemometre <= '1';
             wait for 30*CLK_PER;
        end loop ; 
        wait;
    end process pAnemo;


    pSrtStp : process 
    begin
        start_stop <= '1';
        --wait for 30000 ns;
        --start_stop <= '0';
        --wait for 60 ns;
        wait; 
    end process pSrtStp;

    pContinue : process
    begin 
        continu <= '0';
        wait for 25*CLK_PER;
        continu <= '1';
        wait; 
    end process pContinue;




    anemometre_1 : entity work.gestion_boutton
        port map (
            clk_50M            => Clk,
            in_freq_anemometre => in_freq_anemometre,
            reset_n            => SRst,
            continu            => continu,
            start_stop         => start_stop,
            data_valid         => data_valid,
            data_anemometre    => data_anemometre
        );

    

  


end architecture rtl;