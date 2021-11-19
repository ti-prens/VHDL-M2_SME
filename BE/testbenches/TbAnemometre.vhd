library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity TbAnemometre is
--no inputs and outputs
end entity TbAnemometre;

architecture rtl of TbAnemometre is
    constant CLK_PER          : time := 20 ns;
    signal Clk                : std_logic;
    signal SRst               : std_logic;
    signal continu            : std_logic;
    signal in_freq_anemometre : std_logic;
    signal start_stop         : std_logic;
    signal data_valid         : std_logic;
    signal data_anemometre    : std_logic_vector ( 7 downto 0);

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




    anemometre_1 : entity work.anemometre
        port map (
            clk_50M            => Clk,
            in_freq_anemometre => in_freq_anemometre,
            reset_n            => SRst,
            continu            => continu,
            start_stop         => start_stop,
            data_valid         => data_valid,
            data_anemometre    => data_anemometre
        );

    

    --Fpwm = Fclk / ( (Autoreload + 1) * (Prescaler + 1)

    --Prescaler  <= x"0004"; -- Prescaler == PSC
    --Autoreload <= x"270F"; -- 40 en hexa
                           -- ARR == Autoreload  


end architecture rtl;