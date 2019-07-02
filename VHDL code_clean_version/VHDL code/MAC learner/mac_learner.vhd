library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mac_learner is --1 learner & 4 handlers
  port ( 
    clk            : in std_logic; -- system clock
    reset          : in std_logic; -- asynchronous reset
    mac_req        : in std_logic_vector(3 downto 0);
    mac_addr       : in std_logic_vector(383 downto 0);
	ctrl_flag_mac  : out std_logic_vector(15 downto 0)
	);
end mac_learner;

ARCHITECTURE mac_learner_arch OF mac_learner IS
signal data_from_ram_f : std_logic_vector(49 downto 0);
signal hash_addr_f : std_logic_vector(11 downto 0);
signal data_to_ram_f : std_logic_vector(49 downto 0);
signal wr_en_ram : std_logic;
signal rd_en_ram : std_logic;
  
component mac_addr_processor 
  port ( 
	clk            : in std_logic; 
    reset          : in std_logic; 
    mac_req_0      : in std_logic;
    mac_req_1      : in std_logic;
    mac_req_2      : in std_logic;
    mac_req_3      : in std_logic;
    mac_addr_0 : in std_logic_vector(95 downto 0); 
	mac_addr_1 : in std_logic_vector(95 downto 0); 
	mac_addr_2 : in std_logic_vector(95 downto 0);
	mac_addr_3 : in std_logic_vector(95 downto 0); 
	data_from_ram  : in std_logic_vector(49 downto 0);
	ctrl_flag_0    : out std_logic_vector(3 downto 0); 
	ctrl_flag_1    : out std_logic_vector(3 downto 0); 
	ctrl_flag_2    : out std_logic_vector(3 downto 0); 
	ctrl_flag_3    : out std_logic_vector(3 downto 0); 
	hash_addr      : out std_logic_vector(11 downto 0); 
	data_to_ram    : out std_logic_vector(49 downto 0);
	wr_en          : out std_logic;
	rd_en          : out std_logic
	);
end component;

component lookup_RAM 
	PORT
	(
	address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
	clock		: IN STD_LOGIC  := '1';
	data		: IN STD_LOGIC_VECTOR (49 DOWNTO 0);
	rden		: IN STD_LOGIC  := '1';
	wren		: IN STD_LOGIC ;
	q		: OUT STD_LOGIC_VECTOR (49 DOWNTO 0)
	);
end component;

BEGIN
mac_addr_proc : mac_addr_processor port map(
    clk  => clk,
    reset => reset,
    mac_req_0 => mac_req(0),
    mac_req_1 => mac_req(1),
    mac_req_2 => mac_req(2),
    mac_req_3 => mac_req(3),
    mac_addr_0 => mac_addr(95 downto 0),
	mac_addr_1 => mac_addr(191 downto 96),
	mac_addr_2 => mac_addr(287 downto 192),
	mac_addr_3 => mac_addr(383 downto 288),
	data_from_ram => data_from_ram_f,
	ctrl_flag_0 => ctrl_flag_mac(3 downto 0),
	ctrl_flag_1 => ctrl_flag_mac(7 downto 4),  
	ctrl_flag_2 => ctrl_flag_mac(11 downto 8),   
	ctrl_flag_3 => ctrl_flag_mac(15 downto 12), 
	hash_addr => hash_addr_f,
	data_to_ram => data_to_ram_f,  
	wr_en => wr_en_ram,
	rd_en => rd_en_ram
	);
	 
look_up_ram : lookup_RAM port map(
	address	=> hash_addr_f,
	clock	=>  clk,
	data	=> data_to_ram_f,
	rden	=> rd_en_ram,
	wren	=> wr_en_ram,
	q	=> data_from_ram_f
	);
end mac_learner_arch;
  