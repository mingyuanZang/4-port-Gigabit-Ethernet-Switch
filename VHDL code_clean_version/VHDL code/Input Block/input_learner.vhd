library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity input_learner is --1 learner & 4 handlers
  port ( 
	clk            : in std_logic; -- system clock
    reset          : in std_logic; -- asynchronous reset
	rx_ctrl        :	in	std_logic_vector(3 downto 0);	--(0)=RXC0...(3=RXC3)
	rx_data        :	in	std_logic_vector(31 downto 0);	--(7 downto 0)=RXD0...(31 downto 24=RXD3)
	ctrl_flag_mac    : in std_logic_vector(15 downto 0); --feedback from mac learner: (11 downto 9) = flag3 from port 3...
	data_out_0       : out std_logic_vector(12 downto 0); --four outputs as to crossbar; (12 downto 10)=ctrl_flag; (9)=end of frame;(8)=start_of_frame 
	data_out_1       : out std_logic_vector(12 downto 0);
	data_out_2       : out std_logic_vector(12 downto 0);
	data_out_3       : out std_logic_vector(12 downto 0);
	mac_req : out std_logic_vector(3 downto 0);
	mac_addr : out std_logic_vector(383 downto 0) -- (383 downto 335) = dest addr from port3, 334 downto 287 is src addr from port3...
	);
end input_learner;

ARCHITECTURE input_learner_arch OF input_learner IS

COMPONENT input_handler
  port ( 
	clk            : in std_logic; 
    reset          : in std_logic; 
	rx_ctrl        :	in	std_logic;	
	data_in        : in std_logic_vector(7 downto 0);
	ctrl_flag_mac  : in std_logic_vector(3 downto 0); 
	data_out       : out std_logic_vector(12 downto 0); 
	mac_addr : out std_logic_vector(95 downto 0); 
	mac_req : out std_logic
	);
END COMPONENT;

BEGIN
input_handler_0 : input_handler PORT MAP (
	clk => clk,        
    reset => reset,       
	rx_ctrl => rx_ctrl(0),
	data_in => rx_data(7 downto 0),      
	ctrl_flag_mac => ctrl_flag_mac(3 downto 0),
	data_out => data_out_0,     
	mac_addr => mac_addr(95 downto 0),
	mac_req => mac_req(0)
);

input_handler_1 : input_handler PORT MAP (
	clk => clk,        
    reset => reset,       
	rx_ctrl => rx_ctrl(1),
	data_in => rx_data(15 downto 8),      
	ctrl_flag_mac => ctrl_flag_mac(7 downto 4),
	data_out => data_out_1,     
	mac_addr => mac_addr(191 downto 96),
	mac_req => mac_req(1)
);

input_handler_2 : input_handler PORT MAP (
	clk => clk,        
    reset => reset,       
	rx_ctrl => rx_ctrl(2),
	data_in => rx_data(23 downto 16),      
	ctrl_flag_mac => ctrl_flag_mac(11 downto 8),
	data_out => data_out_2,     
	mac_addr => mac_addr(287 downto 192),
	mac_req => mac_req(2)
);

input_handler_3 : input_handler PORT MAP (
	clk => clk,        
    reset => reset,       
	rx_ctrl => rx_ctrl(3),
	data_in => rx_data(31 downto 24),      
	ctrl_flag_mac => ctrl_flag_mac(15 downto 12),
	data_out => data_out_3,     
	mac_addr => mac_addr(383 downto 288),
	mac_req => mac_req(3)
);

end input_learner_arch;
