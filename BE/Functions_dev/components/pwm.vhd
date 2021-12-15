--*******************************************************************
-- M2 SME 2021/2022
-- BE Synthèse et mise en œuvre des systèmes 
-- Boukah & Jacquet & Ziane 
--*******************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

entity pwm is 
	generic (
	    H : integer := 16 --taille Prescaler
	);
	port (
		CLOCK, ENABLE, RESET: in std_logic;
		Duty_Cycle, Period_pwm: in std_logic_vector(H-1 downto 0);
		PWm_output	: out std_logic
	);
end entity pwm;

architecture rtl of pwm is
-- on decl	are les variables d e l'architecture avant le premier begin

--Prescaler: in std_logic_vector(P-1 downto 0) := 2;

--signal Prescaler: std_logic_vector(15 downto 0) := x"00ff";
signal reset_synchrone: std_logic; -- 1 pour reset synchrone et 0 pour asynchrone
signal internal_reset : std_logic;
signal sortie_comparateur : std_logic_vector (2 downto 0);
signal sortie_compteur : std_logic_vector (P-1 downto 0);


-- declaration des composants
component diviseur
	generic (
	    P : integer := 3 --taille Prescaler
	);
	port (
		Clock, Enable, Reset: in std_logic;
		Prescaler: in std_logic_vector(P-1 downto 0);
		GeneralOutput	: out std_logic_vector(2 downto 0)
	);
end component diviseur;
 
component comparateur 
  --generic ( Q_1 : integer  : = 5);
    generic (
	    N : integer
	);
	port (
		valeur_a, valeur_b		: in std_logic_vector (N-1 downto 0);
		sortie_comparaison		: out std_logic_vector (2 downto 0) 
		-- sortie_comparaison : 100 => a > b ; 010 => a = b ; 001 => a < b
	);
end component comparateur;

component compteur
	 generic ( N : integer);
    port (
        clk, en, arst_n, SRst: in std_logic;
        q   : out std_logic_vector (N-1 downto 0)
        );
end component compteur;


begin
	
	div: diviseur -- div est une instance du compteur
	generic map (N => P)
		GeneralOutput	:
	port map (Clock => CLOCK,Enable => ENABLE, Reset => internal_reset, Prescaler =>  );
	
	compt: compteur -- compt est une instance du compteur
	generic map (N => P)
	port map (clk => Clock,  arst_n=>'1', en => '1', q => sortie_compteur, SRst => reset_synchrone);
	
	compa1: comparateur -- compa1 est une instance du comparateur
	generic map (N => P)
	port map (valeur_a=>sortie_compteur, valeur_b=>prescaler, sortie_comparaison=>sortie_comparateur);
	
	compa2: comparateur -- compa2 est une instance du comparateur
	generic map (N => P)
	port map (valeur_a=>sortie_compteur, valeur_b=>prescaler, sortie_comparaison=>sortie_comparateur);
	
	
	--internal_areset_n <=   Reset or sortie_comparateur(1) or sortie_comparateur(2);
	reset_synchrone <= Reset or sortie_comparateur(1) or sortie_comparateur(2);
	
	-- le comparateur fonctionne en synchrone 
	GeneralOutput(0) <=  sortie_comparateur(0);
	GeneralOutput(1) <=  sortie_comparateur(1);
	GeneralOutput(2) <=  sortie_comparateur(2);


end architecture rtl;

--generic ( NomVariable : type  : = "valeur");









