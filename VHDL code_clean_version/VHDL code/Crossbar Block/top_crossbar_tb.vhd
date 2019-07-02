
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity top_crossbar_tb is
end entity top_crossbar_tb;

architecture behavior of top_crossbar_tb is
component top_crossbar 
  port ( 
	clk            : in std_logic; -- system clock
    reset          : in std_logic; -- asynchronous reset
	data_in_0     : in std_logic_vector(12 downto 0); --four individual input data and ctrl added
	data_in_1     : in std_logic_vector(12 downto 0); 
	data_in_2     : in std_logic_vector(12 downto 0); 
	data_in_3     : in std_logic_vector(12 downto 0); 
	tx_data        :	out	std_logic_vector(31 downto 0);	--(7 downto 0)=TXD0...(31 downto 24=TXD3)
	tx_ctrl        :	out	std_logic_vector(3 downto 0)	--(0)=TXC0...(3=TXC3)
	);
 end component;

constant clk_period : TIME := 10 ns;
signal clk : std_logic := '0';
signal reset : std_logic;
signal data_in_0_f : std_logic_vector(12 downto 0);
signal data_in_1_f : std_logic_vector(12 downto 0);
signal data_in_2_f : std_logic_vector(12 downto 0);
signal data_in_3_f : std_logic_vector(12 downto 0);
signal tx_data : std_logic_vector(31 downto 0);
signal tx_ctrl : std_logic_vector(3 downto 0);

signal i : natural := 0;
signal seq : natural := 1;

begin
 top_cross : top_crossbar port map(
    clk => clk ,
    reset => reset ,
	data_in_0 => data_in_0_f , 
	data_in_1 => data_in_1_f , 
	data_in_2 => data_in_2_f ,  
	data_in_3 => data_in_3_f ,  
	tx_data => tx_data ,      
	tx_ctrl => tx_ctrl
    );
 
 
 clk_process: process
  begin
    clk <='0'; 
    wait for clk_period/2; 
    clk <='1'; 
    wait for clk_period/2; 
  end process;

  reset <= '1', '0' after 20 ns;
  stimulus : process(reset , clk) is
    constant my_bits : std_logic_vector := X"AAAAAAAAAAAAAAAB0010A47BEA8000123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011E6C53DB2";
    constant data_length : std_logic_vector := "00001001000";
    constant counter_data: integer := my_bits'length /8;
    
    begin
    if reset = '1' then
		data_in_3_f <= (others => '0');
		data_in_2_f <= (others => '0');
		data_in_1_f <= (others => '0');
		data_in_0_f <= (others => '0');
		i <= 0;
    elsif rising_edge(clk) then
      case seq is
		when 1 => 
			if(i = 0) then
			  data_in_0_f <= "10" & data_length;
			  data_in_1_f <= "10" & data_length;
			  data_in_2_f <= "10" & data_length;
			  data_in_3_f <= "10" & data_length;
			  i <= i + 1;
			elsif(i > 0 and i <= counter_data) then
			  data_in_3_f (7) <= my_bits((i-1)*8);
			  data_in_3_f (6) <= my_bits((i-1)*8+1);
			  data_in_3_f (5) <= my_bits((i-1)*8+2);
			  data_in_3_f (4) <= my_bits((i-1)*8+3);
			  data_in_3_f (3) <= my_bits((i-1)*8+4);
			  data_in_3_f (2) <= my_bits((i-1)*8+5);
			  data_in_3_f (1) <= my_bits((i-1)*8+6);
			  data_in_3_f (0) <= my_bits((i-1)*8+7);
			  
			  data_in_2_f (7) <= my_bits((i-1)*8);
			  data_in_2_f (6) <= my_bits((i-1)*8+1);
			  data_in_2_f (5) <= my_bits((i-1)*8+2);
			  data_in_2_f (4) <= my_bits((i-1)*8+3);
			  data_in_2_f (3) <= my_bits((i-1)*8+4);
			  data_in_2_f (2) <= my_bits((i-1)*8+5);
			  data_in_2_f (1) <= my_bits((i-1)*8+6);
			  data_in_2_f (0) <= my_bits((i-1)*8+7);
			  
			  data_in_1_f (7) <= my_bits((i-1)*8);
			  data_in_1_f (6) <= my_bits((i-1)*8+1);
			  data_in_1_f (5) <= my_bits((i-1)*8+2);
			  data_in_1_f (4) <= my_bits((i-1)*8+3);
			  data_in_1_f (3) <= my_bits((i-1)*8+4);
			  data_in_1_f (2) <= my_bits((i-1)*8+5);
			  data_in_1_f (1) <= my_bits((i-1)*8+6);
			  data_in_1_f (0) <= my_bits((i-1)*8+7);
			  
			  data_in_0_f (7) <= my_bits((i-1)*8);
			  data_in_0_f (6) <= my_bits((i-1)*8+1);
			  data_in_0_f (5) <= my_bits((i-1)*8+2);
			  data_in_0_f (4) <= my_bits((i-1)*8+3);
			  data_in_0_f (3) <= my_bits((i-1)*8+4);
			  data_in_0_f (2) <= my_bits((i-1)*8+5);
			  data_in_0_f (1) <= my_bits((i-1)*8+6);
			  data_in_0_f (0) <= my_bits((i-1)*8+7);
			  
			  data_in_0_f(12 downto 8) <= "11110";
			  data_in_1_f(12 downto 8) <= "11110";
			  data_in_2_f(12 downto 8) <= "00010";
			  data_in_3_f(12 downto 8) <= "00010";
	  
			  i <= i + 1;
			elsif(i > counter_data and i < (counter_data + 12))then
			  data_in_3_f <= (others => '0');
			  data_in_2_f <= (others => '0');
			  data_in_1_f <= (others => '0');
			  data_in_0_f <= (others => '0');
			  i <= i + 1;
			elsif(i = (counter_data + 12)) then
			   data_in_3_f <= (others => '0');
			   i <= 0;
			   seq <= seq + 1;
		  end if;
		  
		when 2 => 
		  if(i = 0) then
			  data_in_3_f <= "10" & data_length;
			  data_in_2_f <= (others => '0');
			  data_in_1_f <= (others => '0');
			  data_in_0_f <= (others => '0');
			  i <= i + 1;
			elsif(i > 0 and i <= counter_data) then
			  data_in_3_f (7) <= my_bits((i-1)*8);
			  data_in_3_f (6) <= my_bits((i-1)*8+1);
			  data_in_3_f (5) <= my_bits((i-1)*8+2);
			  data_in_3_f (4) <= my_bits((i-1)*8+3);
			  data_in_3_f (3) <= my_bits((i-1)*8+4);
			  data_in_3_f (2) <= my_bits((i-1)*8+5);
			  data_in_3_f (1) <= my_bits((i-1)*8+6);
			  data_in_3_f (0) <= my_bits((i-1)*8+7);
			  data_in_3_f(12 downto 8) <= "00010";
			  
			  data_in_2_f <= (others => '0');
			  data_in_1_f <= (others => '0');
			  data_in_0_f <= (others => '0');  
			  i <= i + 1;
			elsif(i > counter_data and i < (counter_data + 12))then
			  data_in_3_f <= (others => '0');
			  data_in_2_f <= (others => '0');
			  data_in_1_f <= (others => '0');
			  data_in_0_f <= (others => '0');
			  i <= i + 1;
			elsif(i = (counter_data + 12)) then
			   data_in_3_f <= (others => '0');
			   i <= 0;
			   seq <= seq + 1;
		  end if;  
		when others  => 
		seq <= 0;  
    end case;
    end if;
  end process stimulus;
 end behavior;



