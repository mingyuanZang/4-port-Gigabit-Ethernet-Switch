library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;

entity mac_learner_tb is
end entity mac_learner_tb;

architecture behavior of mac_learner_tb is
  
component mac_learner
  port ( 
    clk            : in std_logic; -- system clock
    reset          : in std_logic; -- asynchronous reset
    mac_req        : in std_logic_vector(3 downto 0);
    mac_addr       : in std_logic_vector(383 downto 0);
	ctrl_flag_mac  : out std_logic_vector(15 downto 0)
	);
end component;
constant clk_period : TIME := 10 ns;
signal clk : std_logic := '0';
signal reset : std_logic;
signal mac_req_f : std_logic_vector(3 downto 0);
signal mac_addr_f :std_logic_vector(383 downto 0);
signal ctrl_flag_mac_f : std_logic_vector(15 downto 0);
signal i: integer :=0;
begin
  mac_learn: mac_learner port map(
    clk  => clk,
    reset  => reset,
    mac_req  => mac_req_f,
    mac_addr  => mac_addr_f,
	ctrl_flag_mac => ctrl_flag_mac_f
  );
 clk_process: process
 begin
    clk <='0'; 
    wait for clk_period/2; 
    clk <='1'; 
    wait for clk_period/2; 
 end process;
 reset <= '1', '0' after 20 ns;
 simulation_process: process(clk,reset) is
 begin
    if (reset = '1')then
		mac_req_f <= (others => '0');
		mac_addr_f <= (others => '0');
		i <= 0;
	elsif (rising_edge(clk)) then
      if (i = 1) then
        mac_req_f <= "1111";
      elsif(i = 7) then
        mac_req_f <= "1110";
      elsif(i = 13) then
        mac_req_f <= "1100";
      elsif (i = 19) then
        mac_req_f <= "1000";
      elsif(i > 24) then
         mac_req_f <= "0000";
      end if;
      if (i = 2) then
        mac_addr_f(383 downto 288) <= X"B3FE0000801408004500002E";
        mac_addr_f(287 downto 192) <= X"0012345678900010A47BEA80";
        mac_addr_f(191 downto 96)  <= X"0010A47BEA80001234567890";
        mac_addr_f(95 downto 0)    <= X"0012345678900010A47BEA80";
      end if;
      i <= i + 1;
    end if;
 end process;

end behavior;
    
