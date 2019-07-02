library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-------------------------
--EXAMPLE FOR SCHEDULER 2
-------------------------
entity scheduler is
  port ( 
	 clk             : in std_logic; -- system clock
   reset           : in std_logic; -- asynchronous reset
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
end scheduler;

ARCHITECTURE scheduler_arch OF scheduler IS
signal counter : integer := 0;
signal count_data : integer := 0;
signal state1_f : std_logic := '0';
signal state2_f : std_logic := '0';
signal state3_f : std_logic := '0';

signal data_length_temp : std_logic_vector(10 downto 0) := (others => '0');

type state_type is (idle, gap, ext_length_s1, forward_data_s1, ext_length_s2, forward_data_s2, ext_length_s3, forward_data_s3, schedule);  --type of state machine.
signal current_s,next_s: state_type;

begin

process (clk)
begin
	if (rising_edge(clk)) then
		if(reset = '1') then
			current_s <= idle;
		else
			current_s <= next_s;   --state change.
		end if;
	end if;
end process;

process(clk) 
begin 
  if rising_edge(clk) then
    if (next_s  /= gap) then 
		counter <= 0;
    else
		counter <= counter + 1;
    end if;
  end if; 
end process;

process(clk) 
begin 
  if rising_edge(clk) then
    if (next_s = idle) then 
        count_data <= 0;
		data_length_temp  <= (others => '0');
		state1_f <= '0';
 	    state2_f <= '0';
 	    state3_f <= '0';
        data_out <= "00000000";
	elsif (next_s = ext_length_s1) then
		state1_f <= '0';
		state2_f <= '0';
		state3_f <= '0';
		count_data <= count_data + 1;
		data_length_temp <= data_fifo_1;
    elsif (next_s = forward_data_s1) then
		state1_f <= '1';
		state2_f <= '0';
  	    state3_f <= '0';
        count_data <= count_data + 1;
        data_out <= data_fifo_1(7 downto 0);
	elsif (next_s = ext_length_s2) then
		state1_f <= '0';
	    state2_f <= '0';
		state3_f <= '0';
		count_data <= count_data + 1;
		data_length_temp <= data_fifo_2;
    elsif(next_s = forward_data_s2) then
        state1_f <= '0';
		state2_f <= '1';
  	    state3_f <= '0';
        count_data <= count_data + 1;
        data_out <= data_fifo_2(7 downto 0);
	elsif (next_s = ext_length_s3) then
		state1_f <= '0';
		state2_f <= '0';
		state3_f <= '0';
		count_data <= count_data + 1;
		data_length_temp <= data_fifo_3;
 	elsif(next_s = forward_data_s3) then
 	    state1_f <= '0';
		state2_f <= '0';
  	    state3_f <= '1';
        count_data <= count_data + 1;
        data_out <= data_fifo_3(7 downto 0);
 	elsif(next_s = schedule) then
 	    count_data <= 0;
		data_out <= "00000000";
	elsif(next_s =  gap) then
		count_data <= 0;
		data_out <= "00000000";
 	else
 	    count_data <= 0;
		data_out <= "00000000";
    end if;
  end if; 
end process;

process (current_s,data_length_temp,counter,count_data,empty_flag_1,empty_flag_2,empty_flag_3,state1_f,state2_f,state3_f)
begin
  case current_s is
	when idle =>        --when current state is idle
		tx_ctrl <= '0';
		if(empty_flag_1 ='1' and empty_flag_2 = '1' and empty_flag_3 = '1') then
			rdreq_1 <= '0';
			rdreq_2 <= '0';
			rdreq_3 <= '0';
			next_s <= idle;
		elsif(empty_flag_1 ='0') then
			next_s <= ext_length_s1;
			rdreq_1 <= '1';
			rdreq_2 <= '0';
			rdreq_3 <= '0';
		elsif(empty_flag_2 ='0') then
			next_s <= ext_length_s2;
			rdreq_2 <= '1';
			rdreq_1 <= '0';
			rdreq_3 <= '0';
		elsif(empty_flag_3 ='0') then
			next_s <= ext_length_s3;
			rdreq_3 <= '1';
			rdreq_1 <= '0';
			rdreq_2 <= '0';
		else
			next_s <= idle;
			rdreq_1 <= '0';
			rdreq_2 <= '0';
			rdreq_3 <= '0';
		end if;
	  
	when gap =>
		rdreq_1 <= '0';
		rdreq_2 <= '0';
		rdreq_3 <= '0';
		tx_ctrl <= '0';
		if(counter <= 9) then
			next_s <= gap;
		else
			next_s <= schedule;
		end if;
		
	when ext_length_s1 =>
		tx_ctrl <= '0';
		rdreq_2 <= '0';
		rdreq_3 <= '0';
		if (count_data < 1) then
			rdreq_1 <= '0';
			next_s <= ext_length_s1;
		else
			rdreq_1 <= '1';
			next_s <= forward_data_s1;
		end if;
		
	when forward_data_s1 =>
		rdreq_2 <= '0';
		rdreq_3 <= '0';
		if(count_data = data_length_temp + 1) then 
			rdreq_1 <= '0';
			tx_ctrl <= '1';
			next_s <= gap;
		else
			next_s <= forward_data_s1;
			rdreq_1 <= '1';
			tx_ctrl <= '1';
		end if;  
		
	when ext_length_s2 =>
		tx_ctrl <= '0';
		rdreq_1 <= '0';
		rdreq_3 <= '0';
		if (count_data < 1) then
			rdreq_2 <= '0';
			next_s <= ext_length_s2;
		else
			rdreq_2 <= '1';
			next_s <= forward_data_s2;
		end if;
		
	when forward_data_s2 =>
		rdreq_1 <= '0';
	    rdreq_3 <= '0';
		if(count_data = data_length_temp + 1) then 
			rdreq_2 <= '0';
			tx_ctrl <= '1';
			next_s <= gap;
		else
			next_s <= forward_data_s2;
			rdreq_2 <= '1';
			tx_ctrl <= '1';
		end if;  
		
	when ext_length_s3 =>
		tx_ctrl <= '0';
		rdreq_1 <= '0';
	   rdreq_2 <= '0';
		if (count_data < 1) then
			rdreq_3 <= '0';
			next_s <= ext_length_s3;
		else
			rdreq_3 <= '1';
			next_s <= forward_data_s3;
		end if;
		
	when forward_data_s3 =>
		rdreq_1 <= '0';
	    rdreq_2 <= '0';
		if(count_data = data_length_temp + 1) then 
			rdreq_3 <= '0';
			tx_ctrl <= '1';
			next_s <= gap;
		else
			next_s <= forward_data_s3;
			rdreq_3 <= '1';
			tx_ctrl <= '1';
		end if;  
		

	when schedule =>
		tx_ctrl <= '0';
		if(state1_f = '1') then
			if(empty_flag_2 = '0') then
				rdreq_1 <= '0';
				rdreq_3 <= '0';
				rdreq_2 <= '1';
				next_s <= ext_length_s2;
			elsif(empty_flag_3 = '0') then
				rdreq_1 <= '0';
				rdreq_2 <= '0';
				rdreq_3 <= '1';
				next_s <= ext_length_s3;	
			elsif(empty_flag_1 = '0') then
				rdreq_1 <= '1';
				rdreq_2 <= '0';
				rdreq_3 <= '0';
				next_s <= ext_length_s1;
			else
				rdreq_1 <= '0';
				rdreq_2 <= '0';
				rdreq_3 <= '0';
				next_s <= idle;
			end if;

		--if(previous_state = state_2)then
		elsif(state2_f = '1') then
			if(empty_flag_3 = '0') then
				rdreq_1 <= '0';
				rdreq_2 <= '0';
				rdreq_3 <= '1';
				next_s <= ext_length_s3;
			elsif(empty_flag_1 = '0') then
				rdreq_1 <= '1';
				rdreq_2 <= '0';
				rdreq_3 <= '0';
				next_s <= ext_length_s1;	
			elsif(empty_flag_2 = '0') then
				rdreq_1 <= '0';
				rdreq_3 <= '0';
				rdreq_2 <= '1';
				next_s <= ext_length_s2;
			else
				rdreq_1 <= '0';
				rdreq_2 <= '0';
				rdreq_3 <= '0';
				next_s <= idle;
			end if;

		--if(previous_state = state_3)then		
		elsif(state3_f = '1') then
			if(empty_flag_1 = '0') then
				rdreq_1 <= '1';
				rdreq_2 <= '0';
				rdreq_3 <= '0';
				next_s <= ext_length_s1;
			elsif(empty_flag_2 = '0') then
				rdreq_1 <= '0';
				rdreq_3 <= '0';
				rdreq_2 <= '1';
				next_s <= ext_length_s2;	
			elsif(empty_flag_3 = '0') then
				rdreq_1 <= '0';
				rdreq_2 <= '0';
				rdreq_3 <= '1';
				next_s <= ext_length_s3;
			else
				rdreq_1 <= '0';
				rdreq_2 <= '0';
				rdreq_3 <= '0';
				next_s <= idle;
			end if;
		else
			rdreq_1 <= '0';
			rdreq_2 <= '0';
			rdreq_3 <= '0';
			next_s <= idle;
		end if;		  	
	end case;
end process;
	
end scheduler_arch;
		
