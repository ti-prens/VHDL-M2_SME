library ieee;
use ieee.std_logic_1164.all;
-- commentaire : On fait une bascule D
-- Il faut un fichier top level : on choisi ce fichier comme top lelevl

-- on cree nos entitées
-- une entité est un composant à realiser qui a des entree et des sorties
entity BasculeD is 
	port (
		Reset 	: in std_logic;
		Set		: in std_logic;
		Clk		: in std_logic;
		D		: in std_logic;
		Q		: out std_logic
	);
end entity BasculeD;

-- l'architecture decrit le fonctionnement de l'entité
architecture rtl of BasculeD is -- rtl -> register transistor level
begin
-- Les processus dans l'architecture sont le detaile de
	pBasculeD : process(Clk,Reset, Set)
	begin
		 if Reset = '1' then 
			Q <= '0';
		 elsif Set = '1' then 
			Q <= '1';
		 elsif rising_edge(Clk) then  -- on rising_edge == Clk'event and Clk
			Q <= D;
		end if;
	end process pBasculeD;
end architecture rtl;