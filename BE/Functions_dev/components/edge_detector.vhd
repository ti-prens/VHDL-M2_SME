--Mouloud ZIANE & Prince JACQUET
--M2 SME
Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity edge_detector is --only detect rising edge
	port(
		clk, f_in : in std_logic;
		reset : in std_logic;
		detected_edge : out std_logic);
end edge_detector;

architecture custom_arc of edge_detector is
	signal f_in_d : std_logic := '0';
begin 
	process(clk) is
	begin	
		if rising_edge(clk) then
		f_in_d <= f_in;

			if reset = '1' then 
				detected_edge <= '0';

			elsif f_in_d = '0' and f_in = '1' then 
				detected_edge <= '1';
			
			else
				detected_edge <= '0';
			end if;
		end if;
	end process;

end custom_arc;