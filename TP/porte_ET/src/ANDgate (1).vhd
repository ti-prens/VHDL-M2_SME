library ieee;
use ieee.std_logic_1164.all;
-- commentaire : On fait une bascule D
-- Il faut un fichier top level : on choisi ce fichier comme top lelevl

-- on cree nos entit�es
-- une entit� est un composant � realiser qui a des entree et des sorties
entity ANDgate is 
	port (
		entree1	: in std_logic;
		entree2 : in std_logic;
		sortie	: out std_logic
	);
end entity ANDgate;

-- l'architecture decrit le fonctionnement de l'entit�
architecture rtl of ANDgate is -- rtl -> register transistor level
begin
	sortie <= entree1  and entree2 ;
end architecture rtl;