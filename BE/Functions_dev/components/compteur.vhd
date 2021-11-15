library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity compteur is
    generic ( N : integer);
    port (
        clk            : in  std_logic; --horloge
        en             : in  std_logic; --enable counting or decounting
        arst_n         : in  std_logic; --reset asynchrone et inverse (1 => pas de reset)
        SRst           : in  std_logic; --reset synchrone
        counter_output : out std_logic_vector (N-1 downto 0)
    );

end entity compteur;



architecture rtl of compteur is

    -- on decl  are les variables d e l'architecture avant le premier begin
    signal count : std_logic_vector (N-1 downto 0) := (others => '0');

begin


    pCompteur : process(clk,arst_n)
    begin

        if arst_n = '0' then --signal reset asynchrone actif
            count <= (others => '0');
        

        elsif rising_edge(clk) then

            if SRst = '1' then
                count <= (others => '0');
            elsif en = '1' then
                count <= count +1;
            end if;

        end if;

    end process pCompteur;

    counter_output <= count;

end architecture rtl;



