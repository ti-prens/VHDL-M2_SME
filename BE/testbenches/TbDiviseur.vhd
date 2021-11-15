library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity TbDiviseur is
end entity TbDiviseur;

architecture rtl of TbDiviseur is
    constant CLK_PER : time := 20 ns;
    signal Clk : std_logic;
    signal ARst_N : std_logic;
    signal Prescaler : std_logic_vector(7 downto 0);
    signal div_output : std_logic;
begin
    
    pRst: process
    begin

        ARst_N <= '1';
        wait for 300 ns;
        ARst_N <= '0';
        wait;
    end process pRst;
    
    pClk: process
    begin
        Clk <= '1';
        wait for CLK_PER / 2;
        Clk <= '0';
        wait for CLK_PER / 2;
    end process pClk;

    diviseur_inst : entity work.diviseur
    generic map (
        P => 8
    )
    port map (
        Clock => Clk,
        Enable => '1',
        Reset => '0',
        Prescaler => Prescaler,
        DivOutput => div_output
    );

    Prescaler <= x"03";

end architecture rtl;