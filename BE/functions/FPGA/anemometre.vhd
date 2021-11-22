--anenometre
library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


--*********************************************
-- module gestion_anemometre
--**********************************************
--entrées:
--clk_50M : hologe 50MHz
--raz_n: rest actif à 0 => initialise le circuit
--in_freq_anemometre: signal de fréquence variable de 0 à 250 HZ
--continu : si=0 mode monocoup, si=1 mode continu
-- en mode continu la donnée est rafraîchie toute les secondes
--start_stop: en monocoup si=1 démarre une acquisition, si =0
-- remet à 0 le signal data_valid
--**************************************************************
-- sorties:
-- data_valid: =1 lorsque une mesure est valide
-- est remis à 0 quand start_stop passe à 0
-- data_anemometre : vitesse vent codée sur 8 bits
--********************************************************************

entity anemometre is
	Port ( clk_50M : in STD_LOGIC;
		in_freq_anemometre : in     std_logic;
		reset_n            : in     std_logic;
		continu            : in     std_logic;
		start_stop         : in     std_logic;
		data_valid         : out    std_logic;
		data_anemometre    : buffer STD_LOGIC_VECTOR(7 downto 0) := (others => '0')
	);
end anemometre;





------------------------------------------------------------------------------------
---------------------------- OVER COMPLICATED ARCH ---------------------------------
------------------------------------------------------------------------------------

architecture anemometre_oc of anemometre is

	--------------------------------------------------------------------------------
	-- on declare les variables de l'architecture avant le premier begin

	--Prescaler: in std_logic_vector(P-1 downto 0) := 2;
	--signal signal_prescaler: std_logic_vector( downto 0) := x"00ff";
	signal timer_enable         : std_logic := '1';
	signal second               : std_logic;
	signal counter              : std_logic_vector (7 downto 0);
	signal internal_reset       : std_logic;
	signal pwm_mode             : std_logic;
	signal rising_edge_detected : std_logic;
	signal sortie_data_valid    : std_logic;


	--------------------------------------------------------------------------------
	-- declaration des composants

	component timer
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
	end component timer;

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


	component edge_detector is
		port (
			clk, f_in     : in  std_logic;
			reset         : in  std_logic;
			detected_edge : out std_logic
		);
	end component edge_detector; --this is a rising edge detector

	--------------------------------------------------------------------------------
	-- description de l'architecture

begin


		compt_front : compteur generic map (N => 8) --doit pouvoir compter jusqua 250 soit 0b11111010
		port map(
			clk            => clk_50M,              --horloge
			en             => rising_edge_detected, --enable counting or decounting
			arst_n         => '1',                  --reset asynchrone et inverse (1 => pas de reset asynchrone)
			SRst           => internal_reset,       --reset synchrone
			counter_output => counter
		);

		timer_1hz : timer generic map (P => 16) --a fixer a 1hz
		port map(
			Clock           => clk_50M,
			Enable          => timer_enable,
			Reset           => internal_reset,
			Enable_PWM      => '0',
			Prescaler       => x"270F", --x"270F", --(10000 - 1) = 9999 = 0x270F               
			Autoreload      => x"1387", --(500 - 1)  = 499 = 0x1F3 (passer de ARR 500 à 5000)               
			Capture_Compare => x"0000",
			coUEV           => second,
			PWM_output      => open,
			tim_counter     => open
		);


	edge_detector_1 : entity work.edge_detector
		port map (
			clk           => clk_50M,
			f_in          => in_freq_anemometre,
			reset         => '0',
			detected_edge => rising_edge_detected
		);


	pEvent : process(clk_50M)
	begin

		if rising_edge(clk_50M) then


			if sortie_data_valid = '1' then
				internal_reset <= '1' ;
			else
				internal_reset <= not reset_n ;
			end if;

			if ((continu = '1' ) or (continu = '0' and start_stop = '1' ))then
				timer_enable <= '1';
			elsif second = '1' and continu = '0' then
				timer_enable <= '0';
			end if;






		end if;
	end process pEvent;


	pOutput : process(clk_50M)

	begin

		if rising_edge(clk_50M) then
			if sortie_data_valid = '1' then
				data_anemometre <= counter;
				data_valid      <= sortie_data_valid;
			end if;


		end if;

	end process pOutput;


	sortie_data_valid <= '1' when second = '1' else '0';	
		--'0' when continu = '0' and start_stop = '0' else
		--'1' when continu = '1' and second = '1' else
		--'1' when continu = '0' and second = '1' else
		--timer must be disable when continu = '0'


	--data_anemometre <= counter;

end architecture anemometre_oc;