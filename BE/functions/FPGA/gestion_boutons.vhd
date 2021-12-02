
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
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY gestion_boutton IS
	PORT (
			 clk_50M: in std_logic;
			 reset_n: in std_logic;
	         BP_Babord: in std_logic;
			 BP_Tribord : in std_logic;
			 BP_STBY  : in std_logic;  
			--ledBabord, ledTribord,ledSTBY, out_bip : out std_logic
			out_bip : out std_logic		  
		  );
END gestion_boutton  ;

ARCHITECTURE arch_gestion_boutton OF gestion_boutton IS
signal fin_tempo, val_tempo, val_bip, fin_bip, bip_simple, bip_double: std_logic;
signal codeFonction: std_logic_vector (3 downto 0);

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

begin

		timer_100hz : timer generic map (P => 16) --a fixer a 100hz
		port map(
			Clock           => clk_50M,
			Enable          => timer_enable,
			Reset           => internal_reset,
			Enable_PWM      => '0',
			Prescaler       => x"0064", --100 valeur calculé               
			Autoreload      => x"1387", -- 5000 c'est une valeur fixé              
			Capture_Compare => x"0000",
			coUEV           => Clk100en,
			PWM_output      => open,
			tim_counter     => open
		);
	--********************************************************************
--state machine bouton poussoir
--************************************************************************
gestion_bp:process (raz_n, Clk100en)
--Avec cette horloge le signal va tres vite, on ne peut  pas  voir tout
--FIXEME
--Idée c'est d'utiliser un génerateur d'impulsion tt les seconds, ce que genere un signal à 20 ns
variable State : State_button;
begin
	if raz_n ='0' then
	state:= s0;
	codeFonction <="0000";
	elsif Clk100en'event and Clk100en='1' then
	case state is
		when s0 =>
		if BP_Babord='0' then 
		state:=s1; codeFonction <="0001";
		end if;
		if BP_Tribord='0' then 
		state:=s2; codeFonction <="0010";
		end if;
		if BP_STBY='0' then 
		state:=s3; codeFonction <="0000"; 
		end if;
		
	when s1 =>
		if BP_Babord='1' then 
		state:=s0; codeFonction <="0000";
		end if;
	when s2 =>
		if BP_Tribord='1' then 
		state:=s0; codeFonction <="0000";
		end if;
		
	when s3 =>
		if BP_STBY='1' then 
		state:=s4; codeFonction <="0011";
		end if;
		
	when s4 =>
		if BP_STBY='0' then 
		state:=s5; -- pas d'action
		end if;
		if BP_Babord='0' then 
		state:=s6; val_tempo <='1'; -- tempo actif 
		end if;
		if BP_Tribord='0' then 
		state:=s9; val_tempo <='1' ;-- tempo actif 
		end if;
	when s5 =>
	if BP_STBY='1' then 
		state:=s0; codeFonction <="0000";
		end if;
	when s6 =>
	if BP_Babord='0' and fin_tempo='1' then 
		state:=s7; codeFonction <="0101";val_tempo <='0'; bip_double<='1';
		end if;
	if BP_Babord='1' and fin_tempo='0' then 
		state:=s8; codeFonction <="0100"; val_tempo <='0'; bip_simple<='1';
		end if;
	when s7 =>
		if fin_bip='1' then 
		state:=s4; codeFonction <="0011"; bip_double<='0';
		end if;
	when s8 =>
		if fin_bip='1' then 
		state:=s4; codeFonction <="0011";bip_simple<='0'; 
		end if;
	end case;

	when s9 =>
		if BP_Tribord='0' and fin_tempo='1' then 
		state:=s10; codeFonction <="0110"; val_tempo <='0'; bip_double<='1';
		end if;
		if BP_Tribord='1' and fin_tempo='0' then 
		state:=s11; codeFonction <="0111"; val_tempo <='0'; bip_simple<='1';
		end if;

	when s10 =>
		if fin_bip='1' then 
		state:=s4; codeFonction <="0011"; bip_double<='0';
		end if;

	when s11 =>
		if fin_bip='1' then 
		state:=s4; codeFonction <="0011"; bip_simple<='0';
		end if;
	end if;
	end process gestion_bp;