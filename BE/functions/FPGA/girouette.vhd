--girouette
--*********************************************************************
-- M2 SME 2021/2022
-- Boukah & Ziane & Jacquet
--********************************************




--********************************************
-- module girouette : mesure pwm
--*********************************************
--entrées:
--clk_50M : hologe 50MHz
--raz_n: rest actif à 0 => initialise le circuit
--in_pwm: pwm a mesurer

--**************************************************************
-- sorties:
-- angle: angle associer a la pwm mesurer
--********************************************************************


entity girouette is
	Port ( 
		clk_50M : in STD_LOGIC;
		in_pwm     : in  std_logic;
		reset_n    : in  std_logic;
		angle      : out std_logic_vector(15 downto 0)
	);
end girouette;

------------------------------------------------------------------------------------
---------------------------- OVER COMPLICATED ARCH ---------------------------------
------------------------------------------------------------------------------------

architecture girouette_oc of girouette is

	--------------------------------------------------------------------------------
	-- on declare les variables de l'architecture avant le premier begin

	--Prescaler: in std_logic_vector(P-1 downto 0) := 2;
	--signal signal_prescaler: std_logic_vector( downto 0) := x"00ff";
	signal timer_enable             : std_logic := '1';
	signal deci_nano                 : std_logic;
	signal period_counter           : std_logic_vector (7 downto 0);
	signal dc_counter           : std_logic_vector (7 downto 0);
	signal pwm_period_counter_reset : std_logic;
	signal pwm_dc_counter_reset     : std_logic;
	signal internal_reset           : std_logic;
	signal pwm_detected_edge        : std_logic;
	signal rising_edge_detected     : std_logic;
	signal sortie_data_valid        : std_logic;

	--------------------------------------------------------------------------------
	-- description de l'architecture

begin
	edge_detector_pwm : entity edge_detector
		port map (
			clk           => clk_50M,
			f_in          => in_pwm,
			reset         => reset,
			detected_edge => pwm_detected_edge
		);

		timer_100khz : timer generic map (P => 16) --a fixer a 100khz
		port map(
			Clock           => clk_50M,
			Enable          => timer_enable,
			Reset           => pwm_counter_reset,
			Enable_PWM      => '0',
			Prescaler       => x"270F", --x"270F", --(10000 - 1) = 9999 = 0x270F               
			Autoreload      => x"CB1F", --(500 - 1)  = 499 = 0x1F3 (passer de ARR 500 à 5000)               
			Capture_Compare => x"0000",
			coUEV           => deci_nano,
			PWM_output      => open,
			tim_counter     => open
		);


	compteur_dc : entity compteur
		generic map (
			N => 16
		)
		port map (
			clk            => clk_50M,
			en             => deci_nano,
			arst_n         => open,
			SRst           => pwm_detected_edge,
			counter_output => dc_counter
		);

	compteur_period : entity compteur
		generic map (
			N => 16
		)
		port map (
			clk            => clk_50M,
			en             => deci_nano,
			arst_n         => open,
			SRst           => pwm_detected_edge,
			counter_output => period_counter
		);



	pOutput : process(clk_50M, reset_n)

	begin

		if rising_edge(clk_50M) then

			if(in_pwm = '1') then
				pwm_counter_reset <= '1';
			elsif(pwm_counter_reset = '1') then
				angle             <= dc_counter;
				pwm_counter_reset <= '0';
			end if;


		end if;

	end process pOutput;


end architecture girouette_oc;



    
