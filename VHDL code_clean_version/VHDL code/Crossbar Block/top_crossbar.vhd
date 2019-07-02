library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top_crossbar is
  port ( 
	clk            : in std_logic; -- system clock
    reset          : in std_logic; -- asynchronous reset
	data_in_0     : in std_logic_vector(12 downto 0); --four individual input data and ctrl added
	data_in_1     : in std_logic_vector(12 downto 0); 
	data_in_2     : in std_logic_vector(12 downto 0); 
	data_in_3     : in std_logic_vector(12 downto 0); 
	tx_ctrl        :	out	std_logic_vector(3 downto 0);	--(0)=TXC0...(3=TXC3)
	tx_data        :	out	std_logic_vector(31 downto 0)	--(7 downto 0)=TXD0...(31 downto 24=TXD3)
	);
end top_crossbar;

ARCHITECTURE top_crossbar_arch OF top_crossbar IS
SIGNAL empty_flag_10_f  : std_logic;
SIGNAL empty_flag_20_f  : std_logic;
SIGNAL empty_flag_30_f  : std_logic;
SIGNAL empty_flag_01_f  : std_logic;
SIGNAL empty_flag_21_f  : std_logic;
SIGNAL empty_flag_31_f  : std_logic;
SIGNAL empty_flag_02_f  : std_logic;
SIGNAL empty_flag_12_f  : std_logic;
SIGNAL empty_flag_32_f  : std_logic;
SIGNAL empty_flag_03_f  : std_logic;
SIGNAL empty_flag_13_f  : std_logic;
SIGNAL empty_flag_23_f  : std_logic;

SIGNAL rdreq_0_f      : std_logic_vector(2 downto 0);
SIGNAL rdreq_1_f      : std_logic_vector(2 downto 0);
SIGNAL rdreq_2_f      : std_logic_vector(2 downto 0);
SIGNAL rdreq_3_f      : std_logic_vector(2 downto 0);  

SIGNAL data_fifo_out_f_01    : std_logic_vector(10 downto 0);
SIGNAL data_fifo_out_f_02    : std_logic_vector(10 downto 0);
SIGNAL data_fifo_out_f_03    : std_logic_vector(10 downto 0);

SIGNAL data_fifo_out_f_10    : std_logic_vector(10 downto 0);
SIGNAL data_fifo_out_f_12    : std_logic_vector(10 downto 0);
SIGNAL data_fifo_out_f_13    : std_logic_vector(10 downto 0);

SIGNAL data_fifo_out_f_20    : std_logic_vector(10 downto 0);
SIGNAL data_fifo_out_f_21    : std_logic_vector(10 downto 0);
SIGNAL data_fifo_out_f_23    : std_logic_vector(10 downto 0);

SIGNAL data_fifo_out_f_30    : std_logic_vector(10 downto 0);
SIGNAL data_fifo_out_f_31    : std_logic_vector(10 downto 0);
SIGNAL data_fifo_out_f_32    : std_logic_vector(10 downto 0);

COMPONENT crossbar_0 
  port ( 
	clk            : in std_logic; 
    reset          : in std_logic; 
	data_in_0      : in std_logic_vector(12 downto 0); --four individual input data and ctrl added
	rdreq          :	in std_logic_vector(2 downto 0); --(2) = buffer 03, (1) buffer 02, (0) buffer 01
	data_fifo_out_01   : out std_logic_vector(10 downto 0); --data comes from crossbar fifo
	data_fifo_out_02   : out std_logic_vector(10 downto 0); --data comes from crossbar fifo
	data_fifo_out_03   : out std_logic_vector(10 downto 0); --data comes from crossbar fifo
	empty_flag_01   : out std_logic;
	empty_flag_02   : out std_logic;
	empty_flag_03   : out std_logic
	);
END COMPONENT;

COMPONENT crossbar_1 
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
END COMPONENT;

COMPONENT crossbar_2 
  port ( 
	clk            : in std_logic; -- system clock
    reset          : in std_logic; -- asynchronous reset
	data_in_2      : in std_logic_vector(12 downto 0); --four individual input data and ctrl added
	rdreq          :	in std_logic_vector(2 downto 0); --(2) = buffer 32, (1) buffer 31, (0) buffer 30
	data_fifo_out_20   : out std_logic_vector(10 downto 0); --data comes from crossbar fifo
	data_fifo_out_21   : out std_logic_vector(10 downto 0); --data comes from crossbar fifo
	data_fifo_out_23   : out std_logic_vector(10 downto 0); --data comes from crossbar fifo
	empty_flag_20   : out std_logic;
	empty_flag_21   : out std_logic;
	empty_flag_23   : out std_logic
	);
END COMPONENT;

COMPONENT crossbar_3 
  port ( 
	clk            : in std_logic; -- system clock
    reset          : in std_logic; -- asynchronous reset
	data_in_3      : in std_logic_vector(12 downto 0); --four individual input data and ctrl added
	rdreq          :	in std_logic_vector(2 downto 0); --(2) = buffer 32, (1) buffer 31, (0) buffer 30
	data_fifo_out_30   : out std_logic_vector(10 downto 0); --data comes from crossbar fifo
	data_fifo_out_31   : out std_logic_vector(10 downto 0); --data comes from crossbar fifo
	data_fifo_out_32   : out std_logic_vector(10 downto 0); --data comes from crossbar fifo
	empty_flag_30   : out std_logic;
	empty_flag_31   : out std_logic;
	empty_flag_32   : out std_logic
	);
END COMPONENT;

COMPONENT scheduler
	port ( 
	clk            : in std_logic; -- system clock
    reset          : in std_logic; -- asynchronous reset
	data_fifo_1     : in std_logic_vector(10 downto 0); --data comes from crossbar fifo
	data_fifo_2     : in std_logic_vector(10 downto 0);
	data_fifo_3     : in std_logic_vector(10 downto 0);
	empty_flag_1  : in std_logic;
	empty_flag_2  : in std_logic;
	empty_flag_3  : in std_logic;
	rdreq_1       : out std_logic;
	rdreq_2       : out std_logic;
	rdreq_3       : out std_logic;
	data_out      : out std_logic_vector(7 downto 0); --data will be directly passed to the output port
	tx_ctrl       : out std_logic
	);
END COMPONENT;


begin

cross_0: crossbar_0 PORT MAP (
	clk => clk,        
    reset => reset,       
	data_in_0 => data_in_0,   
	rdreq => rdreq_0_f,       
	data_fifo_out_01 => data_fifo_out_f_01, 
	data_fifo_out_02 => data_fifo_out_f_02,
	data_fifo_out_03 => data_fifo_out_f_03,
	empty_flag_01 => empty_flag_01_f,
	empty_flag_02 => empty_flag_02_f,  
	empty_flag_03 => empty_flag_03_f 
);

cross_1: crossbar_1 PORT MAP (
	clk => clk,        
    reset => reset,       
	data_in_1 => data_in_1,   
	rdreq => rdreq_1_f,       
	data_fifo_out_10 => data_fifo_out_f_10,
	data_fifo_out_12 => data_fifo_out_f_12,
	data_fifo_out_13 => data_fifo_out_f_13,
	empty_flag_10 => empty_flag_10_f,
	empty_flag_12 => empty_flag_12_f,  
	empty_flag_13 => empty_flag_13_f 
);

cross_2: crossbar_2 PORT MAP (
	clk => clk,        
    reset => reset,       
	data_in_2 => data_in_2,   
	rdreq => rdreq_2_f,       
	data_fifo_out_20 => data_fifo_out_f_20,
	data_fifo_out_21 => data_fifo_out_f_21, 
	data_fifo_out_23 => data_fifo_out_f_23, 
	empty_flag_20 => empty_flag_20_f,
	empty_flag_21 => empty_flag_21_f,  
	empty_flag_23 => empty_flag_23_f 
);

cross_3: crossbar_3 PORT MAP (
	clk => clk,        
    reset => reset,       
	data_in_3 => data_in_3,   
	rdreq => rdreq_3_f,       
	data_fifo_out_30 => data_fifo_out_f_30,
	data_fifo_out_31 => data_fifo_out_f_31,
	data_fifo_out_32 => data_fifo_out_f_32,
	empty_flag_30 => empty_flag_30_f,
	empty_flag_31 => empty_flag_31_f,  
	empty_flag_32 => empty_flag_32_f 
);



scheduler_0: scheduler PORT MAP (
	 clk => clk,  
    reset => reset,
	 data_fifo_1 => data_fifo_out_f_10, 
	 data_fifo_2 => data_fifo_out_f_20,
	 data_fifo_3 => data_fifo_out_f_30,
	 empty_flag_1 => empty_flag_10_f,
	 empty_flag_2 => empty_flag_20_f,
	 empty_flag_3 => empty_flag_30_f,
	 rdreq_1 => rdreq_1_f(0), 
	 rdreq_2 => rdreq_2_f(0),
	 rdreq_3 => rdreq_3_f(0),
	 data_out => tx_data(7 downto 0),
	 tx_ctrl => tx_ctrl(0)
);

scheduler_1: scheduler PORT MAP (
	 clk => clk,  
    reset => reset,
   data_fifo_1 => data_fifo_out_f_01, 
	 data_fifo_2 => data_fifo_out_f_21,
	 data_fifo_3 => data_fifo_out_f_31,
	 empty_flag_1 => empty_flag_01_f,
	 empty_flag_2 => empty_flag_21_f,
	 empty_flag_3 => empty_flag_31_f,
	 rdreq_1 => rdreq_0_f(0), 
	 rdreq_2 => rdreq_2_f(1),
	 rdreq_3 => rdreq_3_f(1),
	 data_out => tx_data(15 downto 8),
	 tx_ctrl => tx_ctrl(1)
);

scheduler_2: scheduler PORT MAP (
	 clk => clk,  
    reset => reset,
	 data_fifo_1 => data_fifo_out_f_02, 
	 data_fifo_2 => data_fifo_out_f_12,
	 data_fifo_3 => data_fifo_out_f_32, 
	 empty_flag_1 => empty_flag_02_f,
	 empty_flag_2 => empty_flag_12_f,
	 empty_flag_3 => empty_flag_32_f,
	 rdreq_1 => rdreq_0_f(1), 
	 rdreq_2 => rdreq_1_f(1),
	 rdreq_3 => rdreq_3_f(2),
	 data_out => tx_data(23 downto 16),
	 tx_ctrl => tx_ctrl(2)
);

scheduler_3: scheduler PORT MAP (
	clk => clk,  
    reset => reset,
	data_fifo_1 => data_fifo_out_f_03, 
	data_fifo_2 => data_fifo_out_f_13,
	data_fifo_3 => data_fifo_out_f_23, 
	empty_flag_1 => empty_flag_03_f,
	empty_flag_2 => empty_flag_13_f,
	empty_flag_3 => empty_flag_23_f,
	rdreq_1 => rdreq_0_f(2), 
	rdreq_2 => rdreq_1_f(2),
	rdreq_3 => rdreq_2_f(2),
	data_out => tx_data(31 downto 24),
	tx_ctrl => tx_ctrl(3)
);


end top_crossbar_arch;