--*********************************************************************
-- M2 SME 2021/2022
-- Boukah & Ziane & Jacquet
--*********************************************************************
--          Giroutte  
--********************************************************************   
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;



entity GIROUETTE is
    Port ( clock : in STD_LOGIC;
           pwm : in std_logic;
			  reset_n : in std_logic;
           angle : out STD_LOGIC_VECTOR(9 downto 0) := (others => '0')
           );
end GIROUETTE;