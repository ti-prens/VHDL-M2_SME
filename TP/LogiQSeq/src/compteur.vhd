library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;



entity compteur is 
	port (
		Clk, En, ARst : in std_logic;
		Q	: inout bit_vector (7 downto 0)
	);
end entity compteur;

architecture rtl of compteur is
-- on decl	are les variables d e l'architecture avant le premier begin
begin
	pcompteur : process(Clk, ARst, En)
	begin 
		 if ARst = '0' then 
			Q <= "00000000";
		 elsif  rising_edge(Clk) then
			 if En = '1' then  -- on rising_edge == Clk'event and Clk
				Q <= Q +1  ;
			 end if;
		 end if;	
	end process pcompteur;

end architecture rtl;