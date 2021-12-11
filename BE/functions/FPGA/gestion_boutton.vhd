
--*********************************************************************
-- M2 SME 2021/2022
-- Boukah & Ziane & Jacquet
--*********************************************************************
--          module gestion des boutons poussoirs 
--********************************************************************
-- entrées: BP_Babord,BP_Tribord, BP_STBY, clk, reset_n
-- sorties: codeFonction, ledBabord, ledTribord,ledSTBY, out_bip
--**********************************************************************
--clk: horloge à 50MHz
-- reset_n: actif à 0 => initialise le circuit
-- valeurs de codeFonction:
-- =0000: pas d'action, 
-- =0001: mode manuel action vérin babord
-- =0010: mode manuel action vérin tribord
-- =0011: mode pilote automatique/cap
-- =0100: incrément de 1° consigne de cap
-- =0101: incrément de 10° consigne de cap
-- =0111: décrément de 1° consigne de cap
-- =0110: décrément de 10° consigne de cap
--*********************************************************************


LIBRARY ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity gestion_boutton is
	PORT (
		clk_50M        : in  std_logic;
		reset_n        : in  std_logic;
		PB_Babord      : in  std_logic;
		PB_Tribord     : in  std_logic;
		PB_STBY        : in  std_logic;
		ledBabord      : out std_logic;
		ledTribord     : out std_logic;
		ledSTBY        : out std_logic;
		out_bip : out std_logic;
		codeFonction   : out std_logic_vector (3 downto 0)
	);
end gestion_boutton ;



------------------------------------------------------------------------------------
--------------------------------- INSPIRED ARCH ------------------------------------
------------------------------------------------------------------------------------

architecture arch_gestion_boutton of gestion_boutton is

	--------------------------------------------------------------------------------
	-- on declare les variables de l'architecture 
	--------------------------------------------------------------------------------

	signal blink             : std_logic :='0';
	signal Clk500ms : std_logic;
	signal half_on  : std_logic;


	signal bip_simple : std_logic;
	signal bip_double : std_logic;
	signal bip_end    : std_logic;
	signal bip_reset  : std_logic;
	signal not_bip_reset_n : std_logic;
	signal bip_counter : std_logic_vector(15 downto 0) := (others => '0');

	signal internal_reset    : std_logic;
	signal timer_100ms_reset : std_logic := '1';
	signal pwm_reset         : std_logic;

	signal reset_Delay : std_logic;
	signal Delay       : std_logic_vector(15 downto 0) := (others => '0');
	
	
	signal BP_Babord      :  std_logic;
	signal BP_Tribord     :   std_logic;
	signal BP_STBY        :   std_logic;
	
	
	
	signal 	PB_Babord_d     :   std_logic;
	signal	PB_Tribord_d    :   std_logic;
	signal	PB_STBY_d       :   std_logic;
	
	signal mili_s :  std_logic;

	signal Clk_detected_edge : std_logic;
	--signal codeFonction   : std_logic_vector (3 downto 0);

	--------------------------------------------------------------------------------
	-- declaration des composants
	--------------------------------------------------------------------------------

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

	component edge_detector is
		port (
			clk, f_in     : in  std_logic;
			reset         : in  std_logic;
			detected_edge : out std_logic
		);
	end component edge_detector;


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
	
	

	--------------------------------------------------------------------------------
	-- description de l'architecture
	--------------------------------------------------------------------------------

begin

		timer_2hz : timer generic map (P => 16) --a fixer a 2hz => periode de 500ms
		port map(
			Clock           => clk_50M,
			Enable          => '1',
			Reset           => timer_100ms_reset,
			Enable_PWM      => '1',
			Prescaler       => x"270F",--x"2710",--x"03E8", -- 10000 : set presacaler              
			Autoreload      => x"1387",--x"CB20", -- calculate autoreload to have a 500ms period             
			Capture_Compare => x"09C4",
			coUEV           => open,
			PWM_output      => Clk500ms,
			tim_counter     => open
		);
		
		
		

		timer_pwm : timer generic map (P => 16)
		port map (
			Clock           => clk_50M,
			Enable          => '1',
			Reset           => pwm_reset,
			Enable_PWM      => '1',
			Prescaler       => x"01F4",
			Autoreload      => x"03E8",
			Capture_Compare => x"0064", -- DC = ccr / (arr + 1)
			coUEV           => open,
			PWM_output      => half_on, --moitié allumé
			tim_counter     => open
		);
		
		
		
		timer_bip : timer generic map (P => 16)
		port map (
			Clock           => clk_50M,
			Enable          => '1',
			Reset           => not_bip_reset_n,
			Enable_PWM      => '1',
			Prescaler       => x"270F",
			Autoreload      => x"1387",
			Capture_Compare => x"1387", -- DC = ccr / (arr + 1)
			coUEV           => bip_end,
			PWM_output      => bip_simple, --moitié allumé
			tim_counter     => bip_counter
		);
		
		
		timer_debounce : timer generic map (P => 16)
		port map (
			Clock           => clk_50M,
			Enable          => '1',
			Reset           => '0',
			Enable_PWM      => '0',
			Prescaler       => x"03E7",
			Autoreload      => x"01F4",
			Capture_Compare => x"C350", -- DC = ccr / (arr + 1)
			coUEV           => mili_s,
			PWM_output      => open, --moitié allumé
			tim_counter     => open
		);


	edge_detector_1 : edge_detector
		port map (
			clk           => clk_50M,
			f_in          => Clk500ms,
			reset         => internal_reset,
			detected_edge => Clk_detected_edge
		);

	compteur_delay : compteur
		generic map (
			N => 16
		)
		port map (
			clk            => clk_50M,
			en             => Clk_detected_edge,
			arst_n         => '1', --asynchrone reset not used
			SRst           => reset_Delay,
			counter_output => Delay
		);
		
		

		
	

	------------------------------------------------------------------------------------


	
	bip_double <= '0' when (bip_counter < 1250) else
						'1' when (bip_counter >= 1250  and bip_counter < 2500) else
						'0' when (bip_counter >= 2500  and bip_counter < 3740 )else
						'1' when (bip_counter >= 3740  and bip_counter < 5000 )else
						'0';




	not_bip_reset_n  <= not bip_reset;
	internal_reset    <= not reset_n;
	pwm_reset         <= internal_reset;
	timer_100ms_reset <= internal_reset;


	------------------------------------------------------------------------------------
	
	pDebounce : process(clk_50M)
	begin
		
		
		if (rising_edge(clk_50M) and mili_s = '1' ) then 
		
		PB_Babord_d  <= PB_Babord;
		PB_Tribord_d  <= PB_Tribord;
		PB_STBY_d  <= PB_STBY;
		
			if( (PB_STBY_d  = PB_STBY) or (PB_Tribord_d  = PB_Tribord) or (PB_Babord_d  = PB_Babord )  )then
					BP_STBY  <= PB_STBY ;
					BP_Tribord <= PB_Tribord;
					BP_Babord<= PB_Babord;
			end if;
		end if;
	end process pDebounce;
	--------------------------------------------------------------------------------
	--State machine bouton poussoir


	gestion_bp : process (clk_50M, reset_n)
		variable present_State, next_State : integer range 0 to 13 := 0;
	begin
		if(reset_n = '0') then
			present_State := 0;


		elsif rising_edge(clk_50M) then
			case present_State is
				when 0 =>
					if(BP_Tribord = '0') then
						next_State := 2;
					elsif(BP_Babord = '0') then
						next_State := 1;
					elsif (BP_STBY = '0') then
						next_State := 3;
					else
						next_State := present_State;
					end if;

				when 1 =>
					if(BP_Babord = '1') then
						next_State := 0;
					else
						next_State := present_State;
					end if;

				when 2 =>
					if(BP_Tribord = '1') then
						next_State := 0;
					else
						next_State := present_State;
					end if;

				when 3 =>
					if(BP_STBY = '1') then
						next_State := 4;
					else
						next_State := present_State;
					end if;

				when 4 =>
					if (BP_STBY = '0') then
						next_State := 5;
					elsif (BP_Babord = '0') then
						next_State := 6;
					elsif (BP_Tribord = '0') then
						next_State := 7;
					else
						next_State := present_State;
					end if;

				when 5 =>
					if(BP_STBY = '1') then
						next_State := 0;
					else
						next_State := present_State;
					end if;

				when 6 =>
					if (BP_Babord = '0' and Delay >= 2) then
						next_State := 13;
					elsif (BP_Babord = '1' and Delay < 2) then
						next_State := 9;
					else
						next_State := present_State;
					end if;

				when 7 =>
					if (BP_Tribord = '0' and Delay >= 2) then
						next_State := 12;
					elsif (BP_Tribord = '1' and Delay < 2) then
						next_State := 11;
					else
						next_State := present_State;
					end if;

				when 8 =>
					if (bip_end = '1') then
						next_State := 4;
					else
						next_State := present_State;
					end if;

				when 9 =>
					if (bip_end = '1') then
						next_State := 4;
					else
						next_State := present_State;
					end if;

				when 10 =>
					if (bip_end = '1') then
						next_State := 4;
					else
						next_State := present_State;
					end if;

				when 11 =>
					if (bip_end = '1') then
						next_State := 4;
					else
						next_State := present_State;
					end if;

				when 12 => 
				if (BP_Tribord = '1') then
					next_State := 10;	
				else
					next_State := present_State;
				end if;

			when 13 => 
				if (BP_Babord = '1') then
					next_State := 8;	
				else
					next_State := present_State;
				end if;


			end case;

			present_State := next_State;

			case present_State is
				when 0 =>
					codeFonction   <= "0000";
					ledSTBY    <= Clk500ms; --blinking led 1 sec
					ledTribord <= half_on;
					ledBabord  <= half_on;
					out_bip     <= '0';

				when 1 =>
					codeFonction   <= "0001";
					ledSTBY    <= Clk500ms;
					ledTribord <= half_on;
					ledBabord  <= '1';
					out_bip     <= '0';

				when 2 =>
					codeFonction   <= "0010";
					ledSTBY    <= Clk500ms;
					ledTribord <= '1';
					ledBabord  <= half_on;
					out_bip     <= '0';

				when 3 =>
					codeFonction   <= "0000";
					ledSTBY    <= Clk500ms;
					ledTribord <= half_on;
					ledBabord  <= half_on;
					out_bip     <= '0';

				when 4 =>
					codeFonction    <= "0011";
					ledSTBY     <= '1';
					ledTribord  <= half_on;
					ledBabord   <= half_on;
					out_bip     <= '0';
					reset_Delay <= '1';
					bip_reset   <= '0'; --init bip reset

				when 5 =>
					codeFonction   <= "0000";
					ledSTBY    <= Clk500ms;
					ledTribord <= half_on;
					ledBabord  <= half_on;
					out_bip     <= '0';

				when 6 =>
					codeFonction    <= "0011";
					ledSTBY     <= '1';
					ledTribord  <= half_on;
					ledBabord   <= half_on;
					out_bip      <= '0';
					reset_Delay <= '0';

				when 7 =>
					codeFonction    <= "0011";
					ledSTBY     <= '1';
					ledTribord  <= half_on;
					ledBabord   <= half_on;
					out_bip      <= '0';
					reset_Delay <= '0';

				when 8 =>
					codeFonction   <= "0101";
					ledSTBY    <= '1';
					ledBabord  <= bip_double;
					ledTribord <= half_on;
					out_bip     <= bip_double;
					bip_reset  <= '1';

				when 9 =>
					codeFonction   <= "0100";
					ledSTBY    <= '1';
					ledBabord  <= bip_simple;
					ledTribord <= half_on;
					out_bip     <= bip_simple;
					bip_reset  <= '1';

				when 10 =>
					codeFonction   <= "0110";
					ledSTBY    <= '1';
					ledBabord  <= half_on;
					ledTribord <= bip_double;
					out_bip    <= bip_double;
					bip_reset  <= '1';

				when 11 =>
					codeFonction   <= "0111";
					ledSTBY    <= '1';
					ledTribord <= bip_simple;
					ledBabord  <= half_on;
					out_bip     <= bip_simple;
					bip_reset  <= '1';
					
				when 12 =>
				codeFonction <= "0011";
				ledSTBY <= '1';
				ledTribord <= half_on;
				ledBabord <= half_on;
				out_bip <= '0';	

			when 13 =>
				codeFonction <= "0011";
				ledSTBY <= '1';
				ledTribord <= half_on;
				ledBabord <= half_on;
				out_bip <= '0';


			end case;
		end if;
	end process gestion_bp;


end arch_gestion_boutton;


-------------------------------------------------------------------------------------




