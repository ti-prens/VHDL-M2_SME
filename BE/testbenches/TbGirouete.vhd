library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity TbGirouette is
end entity TbGirouette;

architecture rtl of TbGirouette is
    constant CLK_PER : time := 20 ns;
    signal Clk : std_logic;
    signal ARst_N : std_logic;
    signal Prescaler : std_logic_vector(7 downto 0);
    signal div_output : std_logic;
    signal PWM_output : std_logic;
begin
    
    pRst: process
    begin

        ARst_N <= '1';
        wait for 300 ns;
        ARst_N <= '0';
        wait;
    end process pRst;
    
    pClk: process
    begin
        Clk <= '1';
        wait for CLK_PER / 2;
        Clk <= '0';
        wait for CLK_PER / 2;
    end process pClk;



	timer_1 : entity work.timer
		generic map (
			P => P
		)
		port map (
			Clock           => Clk,
			Enable          => '1',
			Reset           => '0',
			Enable_PWM      => '1',
			Prescaler       => Prescaler,
			Autoreload      => Autoreload,
			Capture_Compare => Capture_Compare,
			coUEV           => open,
			PWM_output      => PWM_output,
			tim_counter     => open
		);    


	girouette_2 : entity work.girouette
		port map (
			clk_50M    => Clk,
			in_pwm     => PWM_output,
			reset_n    => reset_n,
			continu    => continu,
			start_stop => start_stop,
			data_valid => data_valid,
			angle      => angle
		);    

end architecture rtl;