
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
			clk, chipselect, write_n, reset_n: in std_logic;
			writedata : in std_logic_vector (31 downto 0);
			address : in std_logic;
			readdata : out std_logic_vector (31 downto 0);
			BP_Babord,BP_Tribord, BP_STBY  : in std_logic;  
			ledBabord, ledTribord,ledSTBY, out_bip : out std_logic		  
		  );
END gestion_boutton  ;

ARCHITECTURE arch_gestion_boutton OF gestion_boutton IS
signal fin_tempo, val_tempo, val_bip, fin_bip, bip_simple, bip_double: std_logic;
signal codeFonction: std_logic_vector (3 downto 0);
signal clk_1Hz, bip, clk_50, clk_100, rst_n : std_logic;
signal compt_bip: integer range 0 to 200;

begin
	--********************************************************************
--state machine bouton poussoir
--************************************************************************
gestion_bp:process (raz_n, clk_100)
variable State : State_button;
begin
	if raz_n ='0' then
	state:= s0;
	codeFonction <="0000";
	elsif clk_100'event and clk_100='1' then
		case etat is 
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
		ledSTBY <= clk_1Hz; ledBabord <= led_faible; ledTribord <= led_faible;
	when s1 =>
		if BP_Babord='1' then 
		state:=s0; codeFonction <="0000";
		end if;
		ledSTBY <= clk_1Hz; ledBabord <= led_faible; ledTribord <= '0';
	when s2 =>
		if BP_Tribord='1' then 
		state:=s0; codeFonction <="0000";
		end if;
		ledSTBY <= clk_1Hz; ledBabord <= '0'; ledTribord <= led_faible;
	when s3 =>
		if BP_STBY='1' then 
		state:=s4; codeFonction <="0011";
		end if;
		ledSTBY <= clk_1Hz; ledBabord <= led_intense; ledTribord <= led_intense;
	when s4 =>
		if BP_STBY='0' then 
		state:=s5; codeFonction <="0000";
		end if;
		if BP_Babord='0' and BP_Tribord='1'then 
		state:=s6; codeFonction <="0011"; val_tempo <='1';
		end if;
		if BP_Tribord='0' and BP_Babord='1'then 
		state:=s9; codeFonction <="0011";val_tempo <='1';
		end if;
		ledSTBY <= '1'; ledBabord <= clk_50; ledTribord <= clk_50;
	when s5 =>
		if BP_STBY='1' then 
		state:=s0; codeFonction <="0000";
		end if;
		ledBabord <= clk_50; ledTribord <= clk_50;
	when s6 =>
		if BP_Babord='0' and fin_tempo='1' then 
		state:=s7; codeFonction <="0101";val_tempo <='0'; bip_double<='1';
		end if;
		if BP_Babord='1' and fin_tempo='0' then 
		state:=s8; codeFonction <="0100"; val_tempo <='0'; bip_simple<='1';
		end if;
		ledBabord <= '0'; ledTribord <= clk_50;
	when s7 =>
		if fin_bip='1' then 
		state:=s13; codeFonction <="0101"; bip_double<='0';
		end if;
		ledBabord <= bip ; ledTribord <= clk_50;
	when s8 =>
		if fin_bip='1' then 
		state:=s4; codeFonction <="0011";bip_simple<='0'; 
		end if;
		ledBabord <= bip ; ledTribord <= clk_50;
	when s9 =>
		if BP_Tribord='0' and fin_tempo='1' then 
		state:=s10; codeFonction <="0110"; val_tempo <='0'; bip_double<='1';
		end if;
		if BP_Tribord='1' and fin_tempo='0' then 
		state:=s11; codeFonction <="0111"; val_tempo <='0'; bip_simple<='1';
		end if;
		ledBabord <= clk_50; ledTribord <= '0';
	when s10 =>
		if fin_bip='1' then 
		state:=s12; codeFonction <="0110"; bip_double<='0';
		end if;
		ledBabord <= clk_50; ledTribord <= bip;
	when s11 =>
		if fin_bip='1' then 
		state:=s4; codeFonction <="0011"; bip_simple<='0';
		end if;
		ledBabord <= clk_50; ledTribord <= bip;
	when s12 =>
		if BP_Tribord='1'  then 
		state:=s4; codeFonction <="0011"; bip_double<='0';
		end if;
		ledBabord <= clk_50; ledTribord <= clk_50;
	when s13 =>
		if BP_Babord='1'  then 
		state:=s4; codeFonction <="0011"; bip_double<='0';
		end if;
		ledBabord <= clk_50; ledTribord <= clk_50;
	end case;
	end if;
	end process gestion_bp;