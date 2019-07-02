library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;

entity crossbar_input_block_tb is
end entity crossbar_input_block_tb;

architecture behavior of crossbar_input_block_tb is
  
 component crossbar_input_block_3 
  port ( 
	clk            : in std_logic; -- system clock
    reset          : in std_logic; -- asynchronous rese
	data_in        : in std_logic_vector(12 downto 0); --four individual input data and ctrl added
	occup_1		      : in std_logic_vector (10 DOWNTO 0);
	occup_2		      : in std_logic_vector (10 DOWNTO 0);
	occup_3		      : in std_logic_vector (10 DOWNTO 0);
	data_fifo_30   : out std_logic_vector(10 downto 0); --data will be sent to crossbar fifo
	data_fifo_31   : out std_logic_vector(10 downto 0); 
	data_fifo_32   : out std_logic_vector(10 downto 0); 
	wr_fifo_flag0  : out std_logic;
	wr_fifo_flag1  : out std_logic;
	wr_fifo_flag2  : out std_logic
	);
 end component;
	 
constant clk_period : TIME := 10 ns;
signal clk : std_logic := '0';
signal reset : std_logic;
signal data_in_3 : std_logic_vector(12 downto 0);

SIGNAL wr_fifo_flag0_f : std_logic;
SIGNAL wr_fifo_flag1_f : std_logic;
SIGNAL wr_fifo_flag2_f : std_logic;
SIGNAL data_fifo_30_f   : std_logic_vector(10 downto 0); --data comes from crossbar fifo
SIGNAL data_fifo_31_f  : std_logic_vector(10 downto 0); --data comes from crossbar fifo
SIGNAL data_fifo_32_f  : std_logic_vector(10 downto 0);

SIGNAL occu_1 : std_logic_vector(10 downto 0);
SIGNAL occu_2 : std_logic_vector(10 downto 0);
SIGNAL occu_3 : std_logic_vector(10 downto 0);

signal i : natural := 0;
signal seq : natural := 1;

begin
cross_in_block : crossbar_input_block_3 PORT MAP (
	clk => clk,      
    reset => reset,   
	data_in => data_in_3, 
	occup_1 => occu_1, 
	occup_2 => occu_2,
	occup_3 => occu_3,   
	data_fifo_30 => data_fifo_30_f,
	data_fifo_31 => data_fifo_31_f, 
	data_fifo_32 => data_fifo_32_f,
	wr_fifo_flag0 => wr_fifo_flag0_f,
	wr_fifo_flag1 => wr_fifo_flag1_f,
	wr_fifo_flag2 => wr_fifo_flag2_f
);


clk_process: process
  begin
    clk <='0'; 
    wait for clk_period/2; 
    clk <='1'; 
    wait for clk_period/2; 
  end process;

  reset <= '1', '0' after 20 ns;
  --rdreq <= "001";
  stimulus : process(reset , clk) is
    constant my_bits :   std_logic_vector := X"AAAAAAAAAAAAAAAB0010A47BEA8000123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011E6C53DB2";
    constant my_bits_1 : std_logic_vector := X"AAAAAAAAAAAAAAAB001111110A47BEA8000123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011E6C53DB23";
    constant my_bits_2 : std_logic_vector := X"AAAAAAAAAAAAAAAB001222245678900010A47BEA8008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011CC830786";
    constant my_bits_3 : std_logic_vector := X"AAAAAAAAAAAAAAAB030405060708090A0B0C0D0E0F1012793D2825";
    constant data_length : std_logic_vector := "00001001000";
    constant data_length_1 : std_logic_vector := "00001001011";
    constant data_length_2 : std_logic_vector := "00001001001";
    constant data_length_3 : std_logic_vector := "00000011011";
    constant counter_data: integer := my_bits'length /8; 
    constant counter_data1: integer := my_bits_1'length /8; 
    constant counter_data2: integer := my_bits_2'length /8; 
    constant counter_data3: integer := my_bits_3'length /8; 
    
    begin
    if reset = '1' then
		data_in_3 <= (others => '0');
		i <= 0;
    elsif rising_edge(clk) then
      case seq is
		when 1 =>                   --test the state outport_0
			occu_1 <= "00000000001"; 
			occu_2 <= "00000000001"; 
			occu_3 <= "00000000001";     
			if(i = 0) then
				data_in_3 <= "10" & data_length;
				i <= i + 1;
			elsif(i > 0 and i <= counter_data) then
				data_in_3 (7) <= my_bits((i-1)*8);
				data_in_3 (6) <= my_bits((i-1)*8+1);
				data_in_3 (5) <= my_bits((i-1)*8+2);
				data_in_3 (4) <= my_bits((i-1)*8+3);
				data_in_3 (3) <= my_bits((i-1)*8+4);
				data_in_3 (2) <= my_bits((i-1)*8+5);
				data_in_3 (1) <= my_bits((i-1)*8+6);
				data_in_3 (0) <= my_bits((i-1)*8+7);
				data_in_3(12 downto 8) <= "00010";
			    i <= i + 1;
			elsif(i > counter_data and i < (counter_data + 5))then
			    data_in_3 <= (others => '0');
			    i <= i + 1;
			elsif(i = (counter_data + 5)) then
			    data_in_3 <= (others => '0');
			    i <= 0;
			    seq <= seq + 1;
			end if;
	   
		when 2 =>                      --test the state outport_1
			occu_1 <= "00000000001"; 
			occu_2 <= "00000000001"; 
			occu_3 <= "00000000001";       
			if(i = 0) then
				data_in_3 <= "10" & data_length_1;
				i <= i + 1;
			elsif(i > 0 and i <= counter_data1) then
				data_in_3 (7) <= my_bits_1((i-1)*8);
				data_in_3 (6) <= my_bits_1((i-1)*8+1);
				data_in_3 (5) <= my_bits_1((i-1)*8+2);
				data_in_3 (4) <= my_bits_1((i-1)*8+3);
				data_in_3 (3) <= my_bits_1((i-1)*8+4);
				data_in_3 (2) <= my_bits_1((i-1)*8+5);
				data_in_3 (1) <= my_bits_1((i-1)*8+6);
			    data_in_3 (0) <= my_bits_1((i-1)*8+7);
				data_in_3(12 downto 8) <= "00110";
			    i <= i + 1;
			elsif(i > counter_data1 and i < (counter_data1 + 5))then
				data_in_3 <= (others => '0');
				i <= i + 1;
			elsif(i = (counter_data1 + 5)) then
				data_in_3 <= (others => '0');
				i <= 0;
				seq <= seq + 1;
			end if;  
			 
		when 3 =>                     --test the state outport_2
			occu_1 <= "00000000001"; 
			occu_2 <= "00000000001"; 
			occu_3 <= "00000000001";       
			if(i = 0) then
				data_in_3 <= "10" & data_length;
				i <= i + 1;
			elsif(i > 0 and i <= counter_data) then
				data_in_3 (7) <= my_bits((i-1)*8);
				data_in_3 (6) <= my_bits((i-1)*8+1);
				data_in_3 (5) <= my_bits((i-1)*8+2);
				data_in_3 (4) <= my_bits((i-1)*8+3);
				data_in_3 (3) <= my_bits((i-1)*8+4);
				data_in_3 (2) <= my_bits((i-1)*8+5);
				data_in_3 (1) <= my_bits((i-1)*8+6);
				data_in_3 (0) <= my_bits((i-1)*8+7);
				data_in_3(12 downto 8) <= "01010";
				i <= i + 1;
			elsif(i > counter_data and i < (counter_data + 5))then
				data_in_3 <= (others => '0');
				i <= i + 1;
			elsif(i = (counter_data + 5)) then
				data_in_3 <= (others => '0');
				i <= 0;
				seq <= seq + 1;
			end if;  
	   
		when 4 =>                         --test the state outport_br
			occu_1 <= "00000000001"; 
			occu_2 <= "00000000001"; 
			occu_3 <= "00000000001";        
			if(i = 0) then
				data_in_3 <= "10" & data_length_1;
				i <= i + 1;
			elsif(i > 0 and i <= counter_data1) then
				data_in_3 (7) <= my_bits_1((i-1)*8);
				data_in_3 (6) <= my_bits_1((i-1)*8+1);
				data_in_3 (5) <= my_bits_1((i-1)*8+2);
				data_in_3 (4) <= my_bits_1((i-1)*8+3);
				data_in_3 (3) <= my_bits_1((i-1)*8+4);
				data_in_3 (2) <= my_bits_1((i-1)*8+5);
				data_in_3 (1) <= my_bits_1((i-1)*8+6);
			    data_in_3 (0) <= my_bits_1((i-1)*8+7);
				data_in_3(12 downto 8) <= "11110";
				i <= i + 1;
			elsif(i > counter_data1 and i < (counter_data1 + 5))then
				data_in_3 <= (others => '0');
				i <= i + 1;
			elsif(i = (counter_data1 + 5)) then
				data_in_3 <= (others => '0');
				i <= 0;
				seq <= seq + 1;
			end if;
	 
		when 5 =>                       --test the state outport_1_2
			occu_1 <= "00000000001"; 
			occu_2 <= "00000000001"; 
			occu_3 <= "11111111000";        
			if(i = 0) then
				data_in_3 <= "10" & data_length_2;
				i <= i + 1;
			elsif(i > 0 and i <= counter_data2) then
				data_in_3 (7) <= my_bits_2((i-1)*8);
				data_in_3 (6) <= my_bits_2((i-1)*8+1);
				data_in_3 (5) <= my_bits_2((i-1)*8+2);
				data_in_3 (4) <= my_bits_2((i-1)*8+3);
				data_in_3 (3) <= my_bits_2((i-1)*8+4);
				data_in_3 (2) <= my_bits_2((i-1)*8+5);
				data_in_3 (1) <= my_bits_2((i-1)*8+6);
				data_in_3 (0) <= my_bits_2((i-1)*8+7);
				data_in_3(12 downto 8) <= "11110";
				i <= i + 1;
			elsif(i > counter_data2 and i < (counter_data2 + 5))then
				data_in_3 <= (others => '0');
				i <= i + 1;
			elsif(i = (counter_data2 + 5)) then
				data_in_3 <= (others => '0');
				i <= 0;
				seq <= seq + 1;
			end if;   
	  
		when 6 =>                       --test the state outport_1_3
			occu_1 <= "00000000001"; 
			occu_2 <= "11111111000"; 
			occu_3 <= "00000000001";        
			if(i = 0) then
				data_in_3 <= "10" & data_length_3;
				i <= i + 1;
			elsif(i > 0 and i <= counter_data3) then
				data_in_3 (7) <= my_bits_3((i-1)*8);
				data_in_3 (6) <= my_bits_3((i-1)*8+1);
				data_in_3 (5) <= my_bits_3((i-1)*8+2);
				data_in_3 (4) <= my_bits_3((i-1)*8+3);
				data_in_3 (3) <= my_bits_3((i-1)*8+4);
				data_in_3 (2) <= my_bits_3((i-1)*8+5);
				data_in_3 (1) <= my_bits_3((i-1)*8+6);
				data_in_3 (0) <= my_bits_3((i-1)*8+7);
				data_in_3(12 downto 8) <= "11110";
				i <= i + 1;
			elsif(i > counter_data3 and i < (counter_data3 + 5))then
				data_in_3 <= (others => '0');
				i <= i + 1;
			elsif(i = (counter_data3 + 5)) then
				data_in_3 <= (others => '0');
				i <= 0;
				seq <= seq + 1;
			end if;
	  
		when 7 =>                       --test the state outport_2_3
			occu_1 <= "11111111000"; 
			occu_2 <= "00000000001"; 
			occu_3 <= "00000000001";        
			if(i = 0) then
			   data_in_3 <= "10" & data_length;
			   i <= i + 1;
			elsif(i > 0 and i <= counter_data) then
			   data_in_3 (7) <= my_bits((i-1)*8);
			   data_in_3 (6) <= my_bits((i-1)*8+1);
			   data_in_3 (5) <= my_bits((i-1)*8+2);
			   data_in_3 (4) <= my_bits((i-1)*8+3);
			   data_in_3 (3) <= my_bits((i-1)*8+4);
			   data_in_3 (2) <= my_bits((i-1)*8+5);
			   data_in_3 (1) <= my_bits((i-1)*8+6);
			   data_in_3 (0) <= my_bits((i-1)*8+7);
			   data_in_3(12 downto 8) <= "11110";
			   i <= i + 1;
			elsif(i > counter_data and i < (counter_data + 5))then
			   data_in_3 <= (others => '0');
			   i <= i + 1;
			elsif(i = (counter_data + 5)) then
			   data_in_3 <= (others => '0');
			   i <= 0;
			   seq <= seq + 1;
			 end if; 
			 
		when 8 =>                       --test the state outport_1 in broadcast case
			occu_1 <= "00000000001"; 
			occu_2 <= "11111111000"; 
			occu_3 <= "11111111000";        
			if(i = 0) then
			   data_in_3 <= "10" & data_length;
			   i <= i + 1;
			elsif(i > 0 and i <= counter_data) then
			   data_in_3 (7) <= my_bits((i-1)*8);
			   data_in_3 (6) <= my_bits((i-1)*8+1);
			   data_in_3 (5) <= my_bits((i-1)*8+2);
			   data_in_3 (4) <= my_bits((i-1)*8+3);
			   data_in_3 (3) <= my_bits((i-1)*8+4);
			   data_in_3 (2) <= my_bits((i-1)*8+5);
			   data_in_3 (1) <= my_bits((i-1)*8+6);
			   data_in_3 (0) <= my_bits((i-1)*8+7);
			   data_in_3(12 downto 8) <= "11110";
			   i <= i + 1;
			elsif(i > counter_data and i < (counter_data + 5))then
			   data_in_3 <= (others => '0');
			   i <= i + 1;
			elsif(i = (counter_data + 5)) then
			   data_in_3 <= (others => '0');
			   i <= 0;
			   seq <= seq + 1;
			end if;
			 
	    when 9 =>                       --test the state outport_2 in broadcast case
			occu_1 <= "11111111000"; 
			occu_2 <= "00000000001"; 
			occu_3 <= "11111111000";        
			if(i = 0) then
			   data_in_3 <= "10" & data_length;
			   i <= i + 1;
			elsif(i > 0 and i <= counter_data) then
			   data_in_3 (7) <= my_bits((i-1)*8);
			   data_in_3 (6) <= my_bits((i-1)*8+1);
			   data_in_3 (5) <= my_bits((i-1)*8+2);
			   data_in_3 (4) <= my_bits((i-1)*8+3);
			   data_in_3 (3) <= my_bits((i-1)*8+4);
			   data_in_3 (2) <= my_bits((i-1)*8+5);
			   data_in_3 (1) <= my_bits((i-1)*8+6);
			   data_in_3 (0) <= my_bits((i-1)*8+7);
			   data_in_3(12 downto 8) <= "11110";
			   i <= i + 1;
			elsif(i > counter_data and i < (counter_data + 5))then
			   data_in_3 <= (others => '0');
			   i <= i + 1;
			elsif(i = (counter_data + 5)) then
			   data_in_3 <= (others => '0');
			   i <= 0;
			   seq <= seq + 1;
			end if;  
			 
		when 10 =>                       --test the state outport_3 in broadcast case
			occu_1 <= "11111111000"; 
			occu_2 <= "11111111000"; 
			occu_3 <= "00000000001";        
			if(i = 0) then
			   data_in_3 <= "10" & data_length;
			   i <= i + 1;
			elsif(i > 0 and i <= counter_data) then
			   data_in_3 (7) <= my_bits((i-1)*8);
			   data_in_3 (6) <= my_bits((i-1)*8+1);
			   data_in_3 (5) <= my_bits((i-1)*8+2);
			   data_in_3 (4) <= my_bits((i-1)*8+3);
			   data_in_3 (3) <= my_bits((i-1)*8+4);
			   data_in_3 (2) <= my_bits((i-1)*8+5);
			   data_in_3 (1) <= my_bits((i-1)*8+6);
			   data_in_3 (0) <= my_bits((i-1)*8+7);
			   data_in_3(12 downto 8) <= "11110";
			   i <= i + 1;
			elsif(i > counter_data and i < (counter_data + 5))then
			   data_in_3 <= (others => '0');
			   i <= i + 1;
			elsif(i = (counter_data + 5)) then
			   data_in_3 <= (others => '0');
			   i <= 0;
			   seq <= seq + 1;
			end if; 
			 
	    when 11 =>                       --test the state discard
			occu_1 <= "11111111000"; 
			occu_2 <= "11111111000"; 
			occu_3 <= "11111111000";        
			if(i = 0) then
			   data_in_3 <= "10" & data_length;
			   i <= i + 1;
			elsif(i > 0 and i <= counter_data) then
			   data_in_3 (7) <= my_bits((i-1)*8);
			   data_in_3 (6) <= my_bits((i-1)*8+1);
			   data_in_3 (5) <= my_bits((i-1)*8+2);
			   data_in_3 (4) <= my_bits((i-1)*8+3);
			   data_in_3 (3) <= my_bits((i-1)*8+4);
			   data_in_3 (2) <= my_bits((i-1)*8+5);
			   data_in_3 (1) <= my_bits((i-1)*8+6);
			   data_in_3 (0) <= my_bits((i-1)*8+7);
			   data_in_3(12 downto 8) <= "11110";
			   i <= i + 1;
			elsif(i > counter_data and i < (counter_data + 5))then
			   data_in_3 <= (others => '0');
			   i <= i + 1;
			elsif(i = (counter_data + 5)) then
			   data_in_3 <= (others => '0');
			   i <= 0;
			   seq <= seq + 1;
			end if; 
	  
	    when others  => 
			seq <= 0;  
    end case; 
end if;
end process stimulus;
  
  
end behavior;