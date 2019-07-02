library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity input_state_machine is
  port ( 
	clk            : in std_logic; -- system clock
    reset          : in std_logic; -- asynchronous reset
	data_in        : in std_logic_vector(7 downto 0);
	empty_lf       : in std_logic;-- empty flag from length & fcs fifo
	lf_fifo_out    : in std_logic_vector(11 downto 0);--data from length & fcs fifo
	ctrl_flag_mac  : in std_logic_vector(3 downto 0); --control flag from mac learner
	data_out       : out std_logic_vector(12 downto 0); --four outputs as to crossbar; (12 downto 10)=ctrl_flag; (9)=end of frame;(8)=start_of_frame 
	mac_req        : out std_logic;
	mac_addr       : out std_logic_vector(95 downto 0); -- (383 downto 335) = dest addr from port0, 334 downto 287 is src addr from port0...
	rdreq          : out std_logic;
	rdreq_lf       : out std_logic -- rdreq from length & fcs fifo
	);
end input_state_machine;

ARCHITECTURE input_state_machine_arch OF input_state_machine IS

SIGNAL mac_addr_temp : std_logic_vector(95 downto 0) := (others =>'0');
SIGNAL ext_count : integer := 0; --for forward state
SIGNAL data_delete : std_logic_vector(7 downto 0) := (others =>'0');
SIGNAL data_length_temp : integer := 0;
SIGNAL data_length_f : std_logic_vector(10 downto 0) := (others =>'0');
SIGNAL ext_count_temp : integer; 
SIGNAL ctrl_from_mac :std_logic_vector(3 downto 0) := (others =>'0'); -- result get from mac processor 

type state_type is (idle,ext_length, ext_mac,wait_lookup,forward_pre,forward_length,forward_mac, forward_data, ext_delete);  --type of state machine.
signal current_s,next_s: state_type;

begin
process (clk)
begin
 if (rising_edge(clk)) then
    if(reset = '1') then
	  current_s <= idle;
    else
	    current_s <= next_s;   --state change.  
        if (next_s = idle) then 
            ext_count <= 0;
            ctrl_from_mac <= (others => '0');
		    data_length_temp <= 0;
		    data_length_f <= (others => '0');
        elsif (next_s = ext_length) then
		    data_length_f <= lf_fifo_out(11 downto 1);
		    data_length_temp <= conv_integer(lf_fifo_out(11 downto 1));		
        elsif (next_s = ext_delete) then
            ext_count <= ext_count + 1; 
            data_delete <= data_in;		
	    elsif(next_s = ext_mac) then
			ext_count <= ext_count + 1; 
			mac_addr_temp(ext_count*8+7 downto ext_count*8) <= data_in;
			mac_addr <= mac_addr_temp;	
	    elsif(next_s = wait_lookup) then
			ext_count <= 0;	
		elsif(next_s = forward_length)then
			ext_count <= ext_count + 1;
			data_out <= "10" & data_length_f;
			ctrl_from_mac <= ctrl_flag_mac;	
		elsif(next_s = forward_pre) then
			ext_count <= ext_count + 1;
			data_out <= ctrl_from_mac & '0' & lf_fifo_out(11 downto 4); 
 	    elsif(next_s = forward_mac) then
 	        ext_count <= ext_count + 1;   
		    data_out<= ctrl_from_mac & '0' & mac_addr_temp(ext_count_temp+7 downto ext_count_temp);
 	    elsif(next_s = forward_data) then
 	        ext_count <= ext_count + 1;
 	        data_out <= ctrl_from_mac & '0' & data_in;
	    else
			ext_count <= 0;
			mac_addr <= (others => '0');
			data_out <= (others => '0');
        end if;
	end if;
  end if; 
end process;

process (current_s, ext_count,empty_lf, ctrl_flag_mac, lf_fifo_out, mac_addr_temp,data_length_temp, data_length_f)

begin
    case current_s is
		when idle =>        --when current state is idle
			ext_count_temp <= 0;
			rdreq <= '0';
			mac_req <= '0';
			if(empty_lf = '0') then
				rdreq_lf <= '0';
				next_s <= ext_length;
			else
				rdreq_lf <= '0';
				next_s <= idle;
			end if;  

		when ext_length =>
			ext_count_temp <= 0;
			mac_req <= '0';
			if(lf_fifo_out(0) = '0') then   
				rdreq_lf <= '1';
				rdreq <= '1';
				next_s <= ext_mac;
			elsif(lf_fifo_out(0) = '1') then
				rdreq <= '1';
				rdreq_lf <= '1';
				next_s <= ext_delete;
			else
				rdreq_lf <= '0';
				rdreq <= '0';		
				next_s <= idle;
			end if;
	 
		when ext_mac =>
			rdreq_lf <= '0';
			ext_count_temp <= 0;
		    if(ext_count = 12) then
			    rdreq <= '0';
			    mac_req <= '1';
			    next_s <= wait_lookup;
		    else
				rdreq <= '1';
				mac_req <= '0';
			    rdreq_lf <= '0';			
			    next_s <= ext_mac;
		    end if;
		
		when wait_lookup =>
			rdreq <= '0';
			rdreq_lf <= '0';
			ext_count_temp <= 0;
			if(ctrl_flag_mac = "0001" or ctrl_flag_mac = "0011" or ctrl_flag_mac = "0101" or ctrl_flag_mac = "0111" or ctrl_flag_mac = "1111") then
				mac_req <= '0';
				next_s <= forward_length;
			else
			    mac_req <= '1';
				next_s <= wait_lookup;
			end if;
		
		when forward_length =>
			rdreq <= '0';
			mac_req <= '0';
			ext_count_temp <= 0;
			if (ext_count < 1) then
				rdreq_lf <= '0';
				next_s <= forward_length; 
			else
				rdreq_lf <= '1';
				next_s <= forward_pre;
			end if;

		when forward_pre =>
			rdreq <= '0';
			mac_req <= '0';
			ext_count_temp <= 0;
			if(ext_count <= 8 and ext_count >= 1) then	
				rdreq_lf <= '1';
				next_s <= forward_pre;
			else
				rdreq_lf <= '0';
				next_s <= forward_mac;
			end if;

		when forward_mac =>
		    mac_req <= '0';
		    rdreq_lf <= '0';
		    if(ext_count < 21 and ext_count >= 9) then
		        ext_count_temp <= (ext_count-9)*8;
			    rdreq <= '0';
		        next_s <= forward_mac;
		    else
		        ext_count_temp <= 0;
			    rdreq <= '1';
			    next_s <= forward_data;
		    end if;
			
		when forward_data =>
			mac_req <= '0';
			rdreq_lf <= '0';
			ext_count_temp <= 0;
			if(ext_count = data_length_temp + 1) then 
				rdreq <= '0';
				next_s <= idle;
			else
			    rdreq <= '1';		  
				next_s <= forward_data;
			end if;  
			  
		when ext_delete =>
			mac_req <= '0';
			rdreq_lf <= '0';
			ext_count_temp <= 0;
		    if(ext_count = data_length_temp - 8) then 
				rdreq <= '0';
				next_s <= idle;
			else
				next_s <= ext_delete;
				 rdreq <= '1';
			end if; 	  		
    end case;
end process;

end input_state_machine_arch;
