library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;

entity comparateur is
	generic (
		N : integer := 0
	);
	port (
		valeur_a, valeur_b : in  std_logic_vector (N-1 downto 0);
		sortie_comparaison : out std_logic_vector (2 downto 0)
	-- sortie_comparaison : 100 => a > b ; 010 => a = b ; 001 => a < b
	);
end entity comparateur;

architecture rtl of comparateur is
	-- on declare les variables de l'architecture avant le premier begin

begin
	pcomparateur : process(valeur_a, valeur_b)
	begin
		if valeur_a = valeur_b then
			sortie_comparaison <= "010";
		elsif unsigned(valeur_a) > unsigned(valeur_b) then
			sortie_comparaison <= "100";
		elsif unsigned(valeur_a) < unsigned(valeur_b) then
			sortie_comparaison <= "001";
		end if;
	end process pcomparateur;

end architecture rtl;
