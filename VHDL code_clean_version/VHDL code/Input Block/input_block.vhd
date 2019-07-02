library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;

entity input_block is
 port (
   clk : in std_logic;
   reset : in std_logic;
   data_in : in std_logic_vector (7 downto 0);
   rx_ctrl : in std_logic;
   full_ctrl : in std_logic;
   data_out : out std_logic_vector (7 downto 0);
   preamble_and_sof : out std_logic_vector(63 downto 0);   
   sof_crc : out std_logic;
   eof : out std_logic;
	data_length : out std_logic_vector (10 downto 0);
   valid : out std_logic
  );
end input_block;

architecture behav of input_block is

signal byte_cnt : std_logic_vector (10 downto 0) := (others =>'0');
signal valid_f : std_logic := '0';
signal eof_f : std_logic := '0';
signal preamble_and_sof_f : std_logic_vector(63 downto 0) := (others =>'0'); --temp signal to save the preamble and start_of_frame & space for sof&eof added

begin
 
process (clk ) is
 begin
  if(rising_edge(clk)) then  
   if(reset = '1') then
    byte_cnt <= (others => '0');
   else
    if ((rx_ctrl = '1' and byte_cnt >= 0 and byte_cnt <= 7) and full_ctrl = '0') then   
        byte_cnt <= byte_cnt + 1;
		preamble_and_sof_f(conv_integer(byte_cnt)*8+7 downto conv_integer(byte_cnt)*8) <= data_in;
	elsif ((rx_ctrl = '1' and byte_cnt > 7) and full_ctrl = '0') then 
      data_out <= data_in;
      byte_cnt <= byte_cnt + 1;
      preamble_and_sof <= preamble_and_sof_f;
    elsif ((rx_ctrl = '0' and byte_cnt > 7) and full_ctrl = '0') then
      eof <= eof_f;
      data_length  <= byte_cnt;
      data_out <= data_in;
      byte_cnt <= (others => '0');
    else
      byte_cnt <= (others => '0');
      preamble_and_sof <= (others => '0');
      eof <= eof_f;
      data_length  <= byte_cnt;
    end if;
   end if;
  end if;
 end process;

process (rx_ctrl, byte_cnt, full_ctrl) is
 begin
  if(rx_ctrl = '1' and byte_cnt <= 8 and full_ctrl = '0') then
 	sof_crc <= '0';
	valid <= '0';
    eof_f <= '0';
  elsif(rx_ctrl = '1' and byte_cnt = 9 and full_ctrl = '0') then
    sof_crc <= '1';
    valid <= '1';
    eof_f <= '0';
  elsif (rx_ctrl = '1' and byte_cnt >= 10 and full_ctrl = '0') then
    sof_crc <= '0';
    valid <= '1';
    eof_f <= '0';
  elsif (rx_ctrl = '0' and byte_cnt > 10 and full_ctrl = '0') then
    eof_f <= '1';
 	valid <= '1';
	sof_crc <= '0';
  else -- we added this because of warning
    eof_f <= '0';
	valid <= '0';
	sof_crc <= '0';
  end if;
 end process;

end architecture behav;
