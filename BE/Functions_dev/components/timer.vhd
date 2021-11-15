library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

--le timer est un peripherique qui sert à declencher un evenement apres un certain nombres de ce temps ( de cycle d'horloge)
-- CE timer peut compter que dans l'ordre croissant et de 0 à son max puis retourne vers 0
-- Il est fait d'un Diviseur de 16 bit par defaut :  pour reduire la frequence de l'horloge qui la cadence
-- + un Compteur qui compte les fronts montant du signal divise
-- + un Comprateur qui fixe la limite haute du compteur et :le reset une fois cette limite atteinte
-- lors d'un debordement ou d'un reset un signal Counter Overflow passe à Un durant un cycle d'horloge 


entity timer is
	generic (
		P : integer := 16 --taille Prescaler
	);
	port (
		Clock, Enable, Reset : in  std_logic;
		Enable_PWM           : in  std_logic;
		Prescaler            : in  std_logic_vector(P-1 downto 0); --prescaler == (PSC + 1) 
		Autoreload           : in  std_logic_vector(P-1 downto 0); --autoreload == (ARR + 1)
		Capture_Compare      : in  std_logic_vector (P-1 downto 0);
		coUEV                : out std_logic; --counter overflow update event
		PWM_output           : out std_logic;
		tim_counter          : out std_logic_vector(P-1 downto 0)
	);
end entity timer;









architecture rtl of timer is

	--------------------------------------------------------------------------------
	-- on declare les variables de l'architecture avant le premier begin

	--Prescaler: in std_logic_vector(P-1 downto 0) := 2;
	--signal signal_prescaler: std_logic_vector( downto 0) := x"00ff";
	signal general_reset : std_logic := '0';
	signal SRst_compt1   : std_logic := '0';
	signal Reset_div     : std_logic := '0';

	signal signal_div    : std_logic;
	signal timer_counter : std_logic_vector (P-1 downto 0);

	signal counter_overflow_d  : std_logic_vector (P-1 downto 0) := (others => '0'); --creer un signal *_d (pour "delay", retard) pour memmoriser l'etat precedent
	signal counter_overflow_re : std_logic;                                          --creer un signal *_re (rising edge) pour 
	signal out_compa           : std_logic_vector (2 downto 0) := (others => '0');

	signal PWM_outputs : std_logic_vector (2 downto 0);

	--signal pwm_mode : std_logic_vector (2 downto 0):= 000; --000 => A REMPLIR LES DIFFERENT MODES


	--------------------------------------------------------------------------------
	-- declaration des composants

	component diviseur
		generic (
			P : integer := 16 --taille Prescaler
		);
		port (
			Clock, Enable, Reset : in  std_logic;
			Prescaler            : in  std_logic_vector(P-1 downto 0); --prescaler == (PSC + 1) : et doit etre  >=1 
			DivOutput            : out std_logic
		);
	end component diviseur;

	component compteur is
		generic (
			N : integer
		);
		port (
			clk            : in  std_logic;
			en             : in  std_logic;
			arst_n         : in  std_logic;
			SRst           : in  std_logic;
			counter_output : out std_logic_vector (N-1 downto 0)
		);
	end component compteur;




	component comparateur is
		generic (
			N : integer
		);
		port (
			valeur_a, valeur_b : in  std_logic_vector (N-1 downto 0);
			sortie_comparaison : out std_logic_vector (2 downto 0)
		-- sortie_comparaison : 100 => a > b ; 010 => a = b ; 001 => a < b
		);
	end component comparateur;



	--------------------------------------------------------------------------------
	-- description de l'architecture

begin

		div : diviseur generic map (P => P)
		port map (
			Clock     => Clock,
			Enable    => Enable,
			Reset     => Reset_div,
			Prescaler => Prescaler,
			DivOutput => signal_div
		);

		compt1 : compteur generic map (N => P)
		port map(
			clk            => Clock,       --horloge
			en             => signal_div,  --enable counting or decounting
			arst_n         => '1',         --reset asynchrone et inverse (1 => pas de reset asynchrone)
			SRst           => SRst_compt1, --reset synchrone
			counter_output => timer_counter
		);

		compa1 : comparateur generic map (N => P)
		port map(
			valeur_a           => timer_counter,
			valeur_b           => Autoreload,
			sortie_comparaison => out_compa
		); -- sortie_comparaison : 100 => a > b ; 010 => a = b ; 001 => a < b

		compa2 : comparateur generic map (N => P )
		port map(
			valeur_a           => timer_counter,
			valeur_b           => Capture_Compare,
			sortie_comparaison => PWM_outputs

		);




	pReset : process(Clock,Reset)
	begin
		--General Reset
		general_reset <= Reset ;
		if rising_edge(Clock) then

			counter_overflow_d <= timer_counter;

			if counter_overflow_d > timer_counter then
				coUEV <= '1';
			else
				coUEV <= '0';
			end if;
			SRst_compt1 <= out_compa(2) or general_reset;
			Reset_div   <= general_reset;

		end if;
	end process pReset;






	tim_counter <= timer_counter;
	PWM_output  <= (PWM_outputs(0) or PWM_outputs(1)) and Enable_PWM;



end architecture rtl;

--generic ( NomVariable : type  : = "valeur");









