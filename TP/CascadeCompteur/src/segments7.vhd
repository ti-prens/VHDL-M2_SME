library ieee;
use ieee.std_logic_1164.all;
-- commentaire : On fait le code VHDL pour un 7 segments
-- Il faut un fichier top level : on choisi ce fichier comme top lelevl

-- on cree nos entit�es
-- une entit� est un composant � realiser qui a des entree et des sorties
entity segments7 is 
	port (
		entre	: in std_logic_vector (3 downto 0);
		seg 	: out std_logic_vector (6 downto 0)
	);
end entity segments7;

-- l'architecture decrit le fonctionnement de l'entit�
architecture rtl of segments7 is -- rtl -> register transistor level
signal var_invers : std_logic_vector (6 downto 0) ;
begin
	 var_invers <= 	"1111110" when (entre = "0000") else
				"0110000" when (entre = "0001") else
				"1101101" when (entre = "0010") else
				"1111001" when (entre = "0011") else
				"0110011" when (entre = "0100") else
				"1011011" when (entre = "0101") else
				"1011111" when (entre = "0110") else
				"1110000" when (entre = "0111") else
				"1111111" when (entre = "1000") else
				"1110011" when (entre = "1001") else
				"1110111" when (entre = "1010") else
				"0011111" when (entre = "1011") else
				"1001110" when (entre = "1100") else
				"0111101" when (entre = "1101") else
				"1001111" when (entre = "1110") else
				"1000111" when (entre = "1111");
				
		seg <= not var_invers;

	
end architecture rtl;