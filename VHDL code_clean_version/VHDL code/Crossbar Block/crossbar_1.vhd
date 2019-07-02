library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity crossbar_1 is
  port ( 
	clk            : in std_logic; -- system clock
    reset          : in std_logic; -- asynchronous reset
	data_in_1      : in std_logic_vector(12 downto 0); --four individual input data and ctrl added
	rdreq          :	in std_logic_vector(2 downto 0); --(2) = buffer 13, (1) buffer 12, (0) buffer 10
	data_fifo_out_10   : out std_logic_vector(10 downto 0); --data comes from crossbar fifo
	data_fifo_out_12   : out std_logic_vector(10 downto 0); --data comes from crossbar fifo
	data_fifo_out_13   : out std_logic_vector(10 downto 0); --data comes from crossbar fifo
	empty_flag_10   : out std_logic;
	empty_flag_12   : out std_logic;
	empty_flag_13   : out std_logic
	);
end crossbar_1;


ARCHITECTURE crossbar_1_arch OF crossbar_1 IS
SIGNAL wr_fifo_flag0_f : std_logic;
SIGNAL wr_fifo_flag1_f : std_logic;
SIGNAL wr_fifo_flag2_f : std_logic;

SIGNAL data_fifo_in_10 : std_logic_vector(10 downto 0);
SIGNAL data_fifo_in_12 : std_logic_vector(10 downto 0);
SIGNAL data_fifo_in_13 : std_logic_vector(10 downto 0);

SIGNAL occu_1 : std_logic_vector(10 downto 0);
SIGNAL occu_2 : std_logic_vector(10 downto 0);
SIGNAL occu_3 : std_logic_vector(10 downto 0);

COMPONENT fifo_crossbar
	PORT (
		clock	: IN STD_LOGIC ;
		sclr	: IN STD_LOGIC ;
		usedw	: OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
		empty	: OUT STD_LOGIC ;
		full	: OUT STD_LOGIC ;
		q	: OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
		wrreq	: IN STD_LOGIC ;
		data	: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
			rdreq	: IN STD_LOGIC 
	);
		END COMPONENT;
	
COMPONENT crossbar_input_block_1
	port ( 
		clk            : in std_logic; 
	    reset          : in std_logic; 
		data_in        : in std_logic_vector(12 downto 0); 
		occup_1		      : in std_logic_vector (10 DOWNTO 0);
		occup_2		      : in std_logic_vector (10 DOWNTO 0);
		occup_3		      : in std_logic_vector (10 DOWNTO 0);
		data_fifo_10   : out std_logic_vector(10 downto 0); 
		data_fifo_12   : out std_logic_vector(10 downto 0); 
		data_fifo_13   : out std_logic_vector(10 downto 0); 
		wr_fifo_flag0  : out std_logic;
		wr_fifo_flag1  : out std_logic;
		wr_fifo_flag2  : out std_logic
	);
	END COMPONENT;

begin


fifo_10: fifo_crossbar PORT MAP (
	clock => clk,
	data => data_fifo_in_10,
	rdreq => rdreq(0),
	sclr => reset,
	wrreq => wr_fifo_flag0_f,
	empty => empty_flag_10,
	full => open,
	q => data_fifo_out_10,
	usedw => occu_1
);

fifo_12: fifo_crossbar PORT MAP (
	clock => clk,
	data => data_fifo_in_12,
	rdreq => rdreq(1),
	sclr => reset,
	wrreq => wr_fifo_flag1_f,
	empty => empty_flag_12,
    full => open, 
	q => data_fifo_out_12,
	usedw => occu_2		
);

fifo_13: fifo_crossbar PORT MAP (
	clock => clk,
	data => data_fifo_in_13,
	rdreq => rdreq(2),
	sclr => reset,
	wrreq => wr_fifo_flag2_f,
	empty => empty_flag_13,
    full => open, 
	q => data_fifo_out_13,
	usedw => occu_3
);


cross_in_block : crossbar_input_block_1 PORT MAP (
	clk => clk,      
    reset => reset,   
	data_in => data_in_1,  
    occup_1 => occu_1,
    occup_2 => occu_2,
    occup_3 => occu_3,   
	data_fifo_10 => data_fifo_in_10,
	data_fifo_12 => data_fifo_in_12, 
	data_fifo_13 => data_fifo_in_13,
	wr_fifo_flag0 => wr_fifo_flag0_f,
	wr_fifo_flag1 => wr_fifo_flag1_f,
	wr_fifo_flag2 => wr_fifo_flag2_f
);
end crossbar_1_arch;

