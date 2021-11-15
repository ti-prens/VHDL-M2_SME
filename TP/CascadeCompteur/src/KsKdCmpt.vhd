library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;


entity KsKdCmpt is 
	port (
		Clock, Enable, AReset_N : in std_logic;
		SEGMENT	: out std_logic_vector (6 downto 0)
	);
end entity KsKdCmpt;

architecture rtl of KsKdCmpt is
-- on decl	are les variables d e l'architecture avant le premier begin
signal internal_enable : std_logic;
signal internal_reset : std_logic;
signal sortie_1 : std_logic_vector (26 downto 0);
signal sortie_2 : std_logic_vector (3 downto 0);

-- declaration du composant horloge
component Compt_1 
  --generic ( Q_1 : integer  : = 5);
  generic (
		N : integer
	);
	port (
		clk, en, arst_n,SRst : in std_logic;
		q	: out std_logic_vector (N-1 downto 0)
	);
end component Compt_1;

component segments7
	port (
		entre	: in std_logic_vector (3 downto 0);
		seg 	: out std_logic_vector (6 downto 0)
	);
end component segments7;



begin

	C1: Compt_1 -- U1 est une instance du cpmt
	generic map (N => 27)
	port map (clk => Clock,  arst_n=>AReset_N, en => Enable, q => sortie_1, SRst => internal_reset);
	
	internal_reset <= internal_enable; 
	internal_enable <= '1'  when (sortie_1 >=50e6) else '0'; 
	
	
	
	C2: Compt_1
	generic map (N => 4)
	port map (clk => Clock, arst_n=>AReset_N, en => internal_enable , q => sortie_2, SRst => '0');

	S1: segments7
	port map(entre=>sortie_2,seg=>SEGMENT);
	
	
	
	
	
	
end architecture rtl;

--generic ( NomVariable : type  : = "valeur");









