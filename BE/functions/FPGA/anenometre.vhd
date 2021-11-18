--anenometre
library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity anemometre is
    Port ( clk_50M : in STD_LOGIC;
           in_freq_anemometre : in std_logic;
			  reset_n : in std_logic;
			  continu : in std_logic;
			  start_stop : in std_logic;
			  data_valid : out std_logic;
           data_anemometre : buffer STD_LOGIC_VECTOR(7 downto 0) := (others => '0')
           );
end anemometre;

