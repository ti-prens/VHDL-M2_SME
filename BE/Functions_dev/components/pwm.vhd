library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

--inspired from ARM achitecture quite badly
entity pwm is 
	generic (
	    H : integer := 16 --taille Prescaler
	);
	port (
		CLOCK, ENABLE, RESET: in std_logic;
		PWM_period: in std_logic_vector(H-1 downto 0);
		PWM_duty_cycle: in std_logic_vector(H-1 downto 0);
		PWM_output	: out std_logic
	);
end entity pwm;




architecture rtl of pwm is
--------------------------------------------------------------------------------
-- on decl	are les variables d e l'architecture avant le premier begin

--signal Prescaler: in std_logic_vector(P-1 downto 0) := 2;
--signal Prescaler: std_logic_vector(15 downto 0) := x"00ff";
signal reset_synchrone: std_logic; -- 1 pour reset synchrone et 0 pour asynchrone
signal internal_reset : std_logic;
signal ccr : std_logic_vector (H-1 downto 0);
signal arr : std_logic_vector (H-1 downto 0);
signal sortie_comparateur_1 : std_logic_vector (2 downto 0);
signal sortie_compteur : std_logic_vector (H-1 downto 0);

--------------------------------------------------------------------------------
-- declaration des composants


	component timer is
		generic (
			P : integer := 16
		);
		port (
			Clock, Enable, Reset : in  std_logic;
			Enable_PWM           : in  std_logic;
			Prescaler            : in  std_logic_vector(P-1 downto 0);
			Autoreload           : in  std_logic_vector(P-1 downto 0);
			Capture_Compare      : in  std_logic_vector (P-1 downto 0);
			coUEV                : out std_logic;
			PWM_output           : out std_logic;
			tim_counter          : out std_logic_vector(P-1 downto 0)
		);
	end component timer;

--------------------------------------------------------------------------------
begin
	
	timer_1 : entity work.timer
		generic map (
			P => H
		)
		port map (
			Clock           => CLOCK,
			Enable          => ENABLE,
			Reset           => RESET,
			Enable_PWM      => '1',
			Prescaler       => Prescaler,
			Autoreload      => Autoreload,
			Capture_Compare => Capture_Compare,
			coUEV           => coUEV,
			PWM_output      => PWM_output,
			tim_counter     => tim_counter
		);	
	
	
	
	

	
	
end architecture rtl;

--generic ( NomVariable : type  : = "valeur");









