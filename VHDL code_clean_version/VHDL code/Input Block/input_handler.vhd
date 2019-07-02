library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity input_handler is
  port ( 
	clk            : in std_logic; -- system clock
    reset          : in std_logic; -- asynchronous reset
	rx_ctrl        :	in	std_logic;	--(0)=RXC0
	data_in        : in std_logic_vector(7 downto 0);
	ctrl_flag_mac  : in std_logic_vector(3 downto 0); --control flag from mac learner
	data_out       : out std_logic_vector(12 downto 0); --four outputs as to crossbar; (12 downto 10)=ctrl_flag; (9)=end of frame;(8)=start_of_frame 
	mac_addr : out std_logic_vector(95 downto 0); -- (383 downto 335) = dest addr from port0, 334 downto 287 is src addr from port0...
	mac_req : out std_logic
	);
end input_handler;

ARCHITECTURE input_handler_arch OF input_handler IS
signal preamble_and_sof_f : std_logic_vector(63 downto 0);
signal sof : std_logic;
signal eof_f : std_logic;
signal sof_crc_f : std_logic;
signal valid : std_logic;

signal valid_f : std_logic;
signal data_out_f : std_logic_vector (7 downto 0);
signal data_length_f : std_logic_vector (10 downto 0);

signal rdreq_f : std_logic := '0';
signal full : std_logic;
signal empty: std_logic;
signal q : std_logic_vector (7 downto 0);

signal fcs_error_f : std_logic := '0';
signal length_fcs_result_f : std_logic_vector(11 downto 0);
signal rdreq_lf_f : std_logic;
signal wrreq_length_f : std_logic;
signal empty_lf_f : std_logic;
signal lf_fifo_out_f : std_logic_vector(11 downto 0);

signal data_from_ram_f : std_logic_vector(63 downto 0);
  
component input_block 
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
 end component;
 
component input_buffer 
 port ( 
    clock		: IN STD_LOGIC ;
	data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
	rdreq		: IN STD_LOGIC ;
	sclr		: IN STD_LOGIC ;
	wrreq		: IN STD_LOGIC ;
	empty		: OUT STD_LOGIC ;
	full		: OUT STD_LOGIC ;
	q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
  );
 end component;

 component crc_check
   port ( 
    clk            : in std_logic; 
    reset          : in std_logic;
	full_ctrl : in std_logic;
	data_in 	 : in std_logic_vector(7 downto 0);
	preamble_and_sof : in std_logic_vector(63 downto 0);
    start_of_frame : in std_logic; 
    eof            : in std_logic;
    frame_length   : in std_logic_vector(10 downto 0);
	wrreq_length   : out std_logic;
	length_fcs_result : out std_logic_vector(11 downto 0)
  );
 end component;

component length_fcs_fifo
	PORT(
	clock		: IN STD_LOGIC ;
	data		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
	rdreq		: IN STD_LOGIC ;
	sclr		: IN STD_LOGIC ;
	wrreq		: IN STD_LOGIC ;
	empty		: OUT STD_LOGIC ;
	full		: OUT STD_LOGIC ;
	q		: OUT STD_LOGIC_VECTOR (11 DOWNTO 0)
	);
end component;

component input_state_machine
  port ( 
	clk            : in std_logic; 
    reset          : in std_logic; 
	data_in        : in std_logic_vector(7 downto 0);
	ctrl_flag_mac  : in std_logic_vector(3 downto 0);  
	empty_lf : in std_logic;
	lf_fifo_out : in std_logic_vector(11 downto 0);
	rdreq          : out std_logic;
	data_out       : out std_logic_vector(12 downto 0); 
	mac_addr : out std_logic_vector(95 downto 0); 
	rdreq_lf : out std_logic; 
	mac_req  : out std_logic	 
	);
  end component;
	 
begin 
in_block : input_block port map(
    clk => clk ,
    reset => reset ,
    data_in => data_in ,
    data_out => data_out_f ,
    rx_ctrl => rx_ctrl,
    full_ctrl => full,
    sof_crc => sof_crc_f,
    preamble_and_sof => preamble_and_sof_f,
    eof => eof_f ,
    valid => valid,
    data_length => data_length_f
);
    
crc : crc_check port map(
  clk => clk , 
  reset => reset ,
  data_in => data_out_f ,
  full_ctrl => full,
  start_of_frame => sof_crc_f,
  preamble_and_sof => preamble_and_sof_f, 
  eof => eof_f ,   
  frame_length => data_length_f ,
  wrreq_length => wrreq_length_f ,
  length_fcs_result => length_fcs_result_f  
);

lf_fifo : length_fcs_fifo port map(
  clock	=> clk ,
	data	=> length_fcs_result_f ,
	rdreq	=> rdreq_lf_f ,
	sclr	=> reset ,	
	wrreq	=> wrreq_length_f ,
	empty	=> empty_lf_f ,
	full	=> open ,	
	q	=> 	lf_fifo_out_f
);

in_buffer : input_buffer port map(
 	clock => clk,	
	data => data_out_f,		
	rdreq => rdreq_f,		
	sclr => reset,		
	wrreq => valid,	
	empty => empty,
	full => full,		
	q  => q		
);
    
in_st_machine : input_state_machine port map(
    clk => clk,
    reset => reset,
	data_in => q,
	ctrl_flag_mac => ctrl_flag_mac,
	empty_lf => empty_lf_f,
	lf_fifo_out => lf_fifo_out_f,
	rdreq => rdreq_f,
	data_out => data_out,
	mac_addr => mac_addr,
	rdreq_lf => rdreq_lf_f,
	mac_req => mac_req
	); 
end input_handler_arch;
