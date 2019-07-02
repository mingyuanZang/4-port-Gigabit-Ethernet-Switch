
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;

entity input_block_tb is
end entity input_block_tb;

architecture behavior of input_block_tb is

component input_learner 
  port ( 
	clk            : in std_logic; 
    reset          : in std_logic;
	rx_ctrl        :	in	std_logic_vector(3 downto 0);	
	rx_data        :	in	std_logic_vector(31 downto 0);	
	ctrl_flag_mac    : in std_logic_vector(15 downto 0); 
	data_out_0       : out std_logic_vector(12 downto 0); 
	data_out_1       : out std_logic_vector(12 downto 0);
	data_out_2       : out std_logic_vector(12 downto 0);
	data_out_3       : out std_logic_vector(12 downto 0);
	mac_addr : out std_logic_vector(383 downto 0); 
	mac_req : out std_logic_vector(3 downto 0)
	);
end component;

constant clk_period : TIME := 10 ns;
signal clk : std_logic := '0';
signal reset : std_logic;
signal data_in_0 : std_logic_vector (0 to 7);
signal data_in_1 : std_logic_vector (0 to 7);
signal data_out_0_f : std_logic_vector (12 downto 0);
signal data_out_1_f : std_logic_vector (12 downto 0);
signal data_out_2_f : std_logic_vector (12 downto 0);
signal data_out_3_f : std_logic_vector (12 downto 0);
signal preamble_and_sof_f : std_logic_vector(79 downto 0);
signal sof : std_logic;
signal eof : std_logic;
signal sof_crc_f : std_logic;
signal valid : std_logic;

signal rdreq_f : std_logic := '0';
signal full : std_logic;
signal empty: std_logic;
signal q : std_logic_vector (7 downto 0);

signal i : natural := 0;

signal fcs_error_f : std_logic := '0';
signal data_out_f : std_logic_vector(12 downto 0);
signal mac_addr_f : std_logic_vector(383 downto 0);
signal mac_req_f : std_logic_vector(3 downto 0);
signal rx_data_f : std_logic_vector(31 downto 0);
signal rx_ctrl_f : std_logic_vector(3 downto 0); 
signal ctrl_flag_mac_f: std_logic_vector(15 downto 0);

signal data_length_f : std_logic_vector (10 downto 0);

signal length_fcs_result_f : std_logic_vector(11 downto 0);
signal rdreq_lf_f : std_logic;
signal wrreq_length_f : std_logic;
signal empty_lf_f : std_logic;
signal lf_fifo_out_f : std_logic_vector(11 downto 0) := (others => '0');

begin
in_learner : input_learner port map(	 
    clk => clk,
    reset => reset,
	rx_ctrl => rx_ctrl_f,
	rx_data => rx_data_f,
	ctrl_flag_mac => ctrl_flag_mac_f, 
	data_out_0 => data_out_0_f, 
	data_out_1 => data_out_1_f,
	data_out_2 => data_out_2_f,
	data_out_3 => data_out_3_f,
	mac_addr => mac_addr_f,
	mac_req => mac_req_f
);

 clk_process: process
  begin
    clk <='0'; 
    wait for clk_period/2; 
    clk <='1'; 
    wait for clk_period/2; 
  end process;

  reset <= '1', '0' after 20 ns;
  ctrl_flag_mac_f <= "0001" & "0011" & "0101" & "0111";
  stimulus : process(reset , clk) is
    constant my_bits_1 : std_logic_vector := X"AAAAAAAAAAAAAAAB3310A47BEA8000123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011E6C53DB2";
    constant my_bits_2 : std_logic_vector := X"AAAAAAAAAAAAAAAB3312345678900010A47BEA8008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011CC830786";
    begin
    if reset = '1' then
        data_in_0 <= (others => '0');
        data_in_1 <= (others => '0');
        rx_ctrl_f <= "0000";
        i <= 0;
    elsif rising_edge(clk) then
        if (i < (my_bits_1 'length /8) and i < (my_bits_2 'length /8)) then
			rx_data_f (7) <= my_bits_1(i*8);
			rx_data_f (6) <= my_bits_1(i*8+1);
			rx_data_f (5) <= my_bits_1(i*8+2);
			rx_data_f (4) <= my_bits_1(i*8+3);
			rx_data_f (3) <= my_bits_1(i*8+4);
			rx_data_f (2) <= my_bits_1(i*8+5);
			rx_data_f (1) <= my_bits_1(i*8+6);
			rx_data_f (0) <= my_bits_1(i*8+7);
			
			rx_data_f (15) <= my_bits_1(i*8);
			rx_data_f (14) <= my_bits_1(i*8+1);
			rx_data_f (13) <= my_bits_1(i*8+2);
			rx_data_f (12) <= my_bits_1(i*8+3);
			rx_data_f (11) <= my_bits_1(i*8+4);
			rx_data_f (10) <= my_bits_1(i*8+5);
			rx_data_f (9) <= my_bits_1(i*8+6);
			rx_data_f (8) <= my_bits_1(i*8+7);
			
			rx_data_f (23) <= my_bits_2(i*8);
			rx_data_f (22) <= my_bits_2(i*8+1);
			rx_data_f (21) <= my_bits_2(i*8+2);
			rx_data_f (20) <= my_bits_2(i*8+3);
			rx_data_f (19) <= my_bits_2(i*8+4);
			rx_data_f (18) <= my_bits_2(i*8+5);
			rx_data_f (17) <= my_bits_2(i*8+6);
			rx_data_f (16) <= my_bits_2(i*8+7);
			
			rx_data_f (31) <= my_bits_1(i*8);
			rx_data_f (30) <= my_bits_1(i*8+1);
			rx_data_f (29) <= my_bits_1(i*8+2);
			rx_data_f (28) <= my_bits_1(i*8+3);
			rx_data_f (27) <= my_bits_1(i*8+4);
			rx_data_f (26) <= my_bits_1(i*8+5);
			rx_data_f (25) <= my_bits_1(i*8+6);
			rx_data_f (24) <= my_bits_1(i*8+7);
			rx_ctrl_f <= "1111";
			i <= i + 1;  
        else
			rx_ctrl_f <= "0000";
        end if;
    end if;
  end process stimulus;
 end behavior;

