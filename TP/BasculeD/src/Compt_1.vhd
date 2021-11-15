library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity Compt_1 is 
    generic ( N : integer);
    port (
    	clk, en, arst_n : in std_logic;
    	q	: out std_logic_vector (N-1 downto 0)
    	);
end entity Compt_1;

architecture rtl of Compt_1 is
-- on decl	are les variables d e l'architecture avant le premier begin
	generic map (N => 32)

signal Q1	: std_logic_vector (n-1 downto 0);
begin
	pCompt_1 : process(Clk, ARst)
	begin 
		 if ARst = '0' then 
			Q1 <= (others => '0');
		 elsif  rising_edge(Clk) then
			 if En = '1' then  -- on rising_edge == Clk'event and Clk
				Q1 <= Q1 + 1;
			 end if;
		 end if;
		 
	end process pCompt_1;

	q<=Q1;	

end architecture rtl;