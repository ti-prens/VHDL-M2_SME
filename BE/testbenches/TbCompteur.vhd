library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity TbCompteur is
end entity TbCompteur;

architecture rtl of TbCompteur is
    constant CLK_PER : time := 20 ns;
    signal Clk : std_logic;
    signal srst: std_logic;
    signal enable: std_logic;
    signal Compteur : std_logic_vector(7 downto 0);
begin
    
    psrst: process
    begin
        srst <= '1';
        wait for 30 ns;
        srst <= '0';
        wait for  100 ns;
    end process psrst;
    
    pClk: process
    begin
        Clk <= '1';
        wait for CLK_PER / 2;
        Clk <= '0';
        wait for CLK_PER / 2;
    end process pClk;


    penable: process
    begin
        enable <= '1';
        wait for 65 ns;
        enable <= '0';
        wait for 40 ns;
    end process penable;

    compteur_inst : entity work.compteur
    generic map (
        N => 8
    )
    port map (
        clk => Clk,
        en => enable, --toujours enable
        arst_n => '1',--reset asynchrone pas utilise
        SRst => srst,
        counter_output=> Compteur


    );

end architecture rtl;