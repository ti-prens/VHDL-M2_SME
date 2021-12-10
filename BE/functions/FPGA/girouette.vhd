--*********************************************************************
-- M2 SME 2021/2022
-- Boukah & Ziane & Jacquet
--*********************************************************************
--          Giroutte  
--********************************************************************   
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;



entity GIROUETTE is
    Port ( clock : in STD_LOGIC;
           pwm : in std_logic;
		 reset_n : in std_logic;
           angle : out STD_LOGIC_VECTOR(9 downto 0) := (others => '0')
           );
end GIROUETTE;

architecture arc_girouette of GIROUETTE is 
	signal int_subclk : std_logic := '0';
	signal reset_n_counter : std_logic := '0';
	signal Etat_haut : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

    	--------------------------------------------------------------------------------
	-- declaration des composants

component compteur is
		generic (
			N : integer
		);
		port (
			clk            : in  std_logic;
			en             : in  std_logic;
			arst_n         : in  std_logic;
			SRst           : in  std_logic;
			counter_output : out std_logic_vector (N-1 downto 0)
		);
	end component compteur;


    --------------------------------------------------------------------------------
	-- description de l'architecture

begin

    		freq_count : compteur generic map (N => 16) 
		port map(
			clk            => clk_50M,              --horloge
			en             =>  --enable counting or decounting
			arst_n         => '1',                  --reset asynchrone et inverse (1 => pas de reset asynchrone)
			SRst           => internal_reset,       --reset synchrone
			counter_output => counter
		);
