library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity crossbar_input_block_2 is
  port ( 
		clk            : in std_logic; -- system clock
	    reset          : in std_logic; -- asynchronous rese
		data_in        : in std_logic_vector(12 downto 0); --four individual input data and ctrl added
		occup_1		      : in std_logic_vector (10 DOWNTO 0);
		occup_2		      : in std_logic_vector (10 DOWNTO 0);
		occup_3		      : in std_logic_vector (10 DOWNTO 0);
		data_fifo_20   : out std_logic_vector(10 downto 0); --data will be sent to crossbar fifo
		data_fifo_21   : out std_logic_vector(10 downto 0); 
		data_fifo_23   : out std_logic_vector(10 downto 0); 
		wr_fifo_flag0  : out std_logic;
		wr_fifo_flag1  : out std_logic;
		wr_fifo_flag2  : out std_logic
		);
end crossbar_input_block_2;

ARCHITECTURE crossbar_input_block_2_arch OF crossbar_input_block_2 IS
SIGNAL counter : integer;
SIGNAL data_length_temp : std_logic_vector(10 downto 0) := (others => '0');
SIGNAL data_in_temp_1 : std_logic_vector(12 downto 0) := (others => '0');
SIGNAL data_in_temp_2 : std_logic_vector(12 downto 0) := (others => '0');

SIGNAL delete_temp : std_logic_vector(12 downto 0) := (others => '0');

SIGNAL occup_1_temp : integer := 0;
SIGNAL occup_2_temp : integer := 0;
SIGNAL occup_3_temp : integer := 0;
SIGNAL length_counter : integer := 0;

type state_type is (idle,ext_length,outport_1,outport_2,outport_3,outport_br,outport_1_2,outport_1_3,outport_2_3,discard);  --type of state machine.
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
    if (next_s = idle) then 
		counter <= 0;
		data_length_temp <= (others => '0');
		data_in_temp_1 <= (others => '0');
		data_in_temp_2  <= (others => '0');
		occup_1_temp <= 2047 - conv_integer(occup_1);
		occup_2_temp <= 2047 - conv_integer(occup_2);
		occup_3_temp <= 2047 - conv_integer(occup_3);
    elsif (next_s = ext_length) then
        counter <= counter + 1;
        data_length_temp <= data_in(10 downto 0);
        length_counter <= conv_integer(data_in(10 downto 0));
        occup_1_temp <= 2047 - conv_integer(occup_1);
        occup_2_temp <= 2047 - conv_integer(occup_2);
        occup_3_temp <= 2047 - conv_integer(occup_3);
    elsif(next_s = outport_1)then
		counter <= counter + 1;
		occup_1_temp <= 2047 - conv_integer(occup_1);
		data_in_temp_1 <= data_in_temp_2;
		data_in_temp_2 <= data_in;
    elsif(next_s = outport_2) then
      	counter <= counter + 1;
      	occup_2_temp <= 2047 - conv_integer(occup_2);
      	data_in_temp_1 <= data_in_temp_2;
		data_in_temp_2 <= data_in;
    elsif(next_s = outport_3) then
 	    counter <= counter + 1;
 	    occup_3_temp <= 2047 - conv_integer(occup_3);
 	    data_in_temp_1 <= data_in_temp_2;
		data_in_temp_2 <= data_in;
 	elsif(next_s = outport_br) then
 	    counter <= counter + 1;
 	    occup_1_temp <= 2047 - conv_integer(occup_1);
 	    occup_2_temp <= 2047 - conv_integer(occup_2);
 	    occup_3_temp <= 2047 - conv_integer(occup_3);
 	    data_in_temp_1 <= data_in_temp_2;
 	    data_in_temp_2 <= data_in;
 	elsif(next_s = outport_1_2) then
 	    counter <= counter + 1;
 	    occup_1_temp <= 2047 - conv_integer(occup_1);
 	    occup_2_temp <= 2047 - conv_integer(occup_2);
 	    data_in_temp_1 <= data_in_temp_2;
 	    data_in_temp_2 <= data_in;
 	elsif(next_s = outport_1_3) then
 	    counter <= counter + 1;
 	    occup_1_temp <= 2047 - conv_integer(occup_1);
 	    occup_3_temp <= 2047 - conv_integer(occup_3);
 	    data_in_temp_1 <= data_in_temp_2;
 	    data_in_temp_2 <= data_in;
 	elsif(next_s = outport_2_3) then
 	    counter <= counter + 1;
 	    occup_2_temp <= 2047 - conv_integer(occup_2);
 	    occup_3_temp <= 2047 - conv_integer(occup_3);
 	    data_in_temp_1 <= data_in_temp_2;
 	    data_in_temp_2 <= data_in;
    elsif(next_s = discard)then
        counter <= counter + 1;
        occup_1_temp <= 2047 - conv_integer(occup_1);
        occup_2_temp <= 2047 - conv_integer(occup_2);
 	    occup_3_temp <= 2047 - conv_integer(occup_3);
        data_in_temp_1 <= data_in_temp_2;
        data_in_temp_2 <= data_in;
	else 
		counter <= 0;
    end if;
  end if; 
end process;

process (current_s,counter,data_in(12 downto 8),length_counter,occup_1_temp,occup_2_temp,occup_3_temp,data_length_temp,data_in_temp_1)
begin
  case current_s is
	when idle =>    
		wr_fifo_flag0 <= '0';
		wr_fifo_flag1 <= '0';
		wr_fifo_flag2 <= '0';
		data_fifo_20 <= (others => '0');
		data_fifo_21 <= (others => '0');
		data_fifo_23 <= (others => '0');
		if(data_in(12 downto 11) = "10") then
			next_s <= ext_length;
		else
			next_s <= idle;
		end if;
		  
	when ext_length => 
		wr_fifo_flag0 <= '0';
		wr_fifo_flag1 <= '0';
		wr_fifo_flag2 <= '0';
		data_fifo_20 <= (others => '0');
		data_fifo_21 <= (others => '0');
		data_fifo_23 <= (others => '0');
		if (data_in(12 downto 8) = "00010") then
			if (length_counter <= occup_1_temp)then 
				next_s <= outport_1;
			else
				next_s <= discard;
			end if;
		elsif(data_in(12 downto 8) = "00110") then
			if (length_counter <= occup_2_temp)then 
				next_s <= outport_2;
			else
				next_s <= discard;
			end if;
		elsif(data_in(12 downto 8) = "01110") then
			if (length_counter <= occup_3_temp)then 
				next_s <= outport_3;
			else
				next_s <= discard;
			end if;
		elsif(data_in(12 downto 8) = "11110") then
			if (length_counter <= occup_1_temp and length_counter <= occup_2_temp and length_counter <= occup_3_temp)then 
				next_s <= outport_br;
			elsif(length_counter <= occup_1_temp and length_counter <= occup_2_temp) then
				next_s <= outport_1_2;
			elsif(length_counter <= occup_1_temp and length_counter <= occup_3_temp) then
				next_s <= outport_1_3;
			elsif(length_counter <= occup_2_temp and length_counter <= occup_3_temp) then
				next_s <= outport_2_3;
			elsif(length_counter <= occup_1_temp) then
				next_s <= outport_1;
			elsif(length_counter <= occup_2_temp) then
				next_s <= outport_2;
			elsif(length_counter <= occup_3_temp) then
				next_s <= outport_3;
			else
				next_s <= discard;
			end if;
		else
			next_s <= ext_length;
		end if;

	   
	when outport_1 => 
		wr_fifo_flag1 <= '0';
		wr_fifo_flag2 <= '0';
		data_fifo_21 <= (others => '0');
		data_fifo_23 <= (others => '0');
		if(counter = 2) then 
			wr_fifo_flag0 <= '1';
			data_fifo_20 <= data_length_temp;
			next_s <= outport_1;
		elsif(counter >= 3 and counter < conv_integer(data_length_temp) + 3) then 
			wr_fifo_flag0 <= '1';
			data_fifo_20 <= "000" & data_in_temp_1(7 downto 0);
			next_s <= outport_1;
		elsif(counter = conv_integer(data_length_temp) + 3) then
		   data_fifo_20 <= (others => '0');
			wr_fifo_flag0 <= '0';
			next_s <= idle;
		else
			data_fifo_20 <= (others => '0');
			wr_fifo_flag0 <= '0';
			next_s <= outport_1;
		end if;
		  
	when outport_2 => 
		wr_fifo_flag0 <= '0';
		wr_fifo_flag2 <= '0';
		data_fifo_20 <= (others => '0');
		data_fifo_23 <= (others => '0');
		if(counter = 2) then 
			wr_fifo_flag1 <= '1';
			data_fifo_21 <= data_length_temp;
			next_s <= outport_2;
	    elsif(counter >= 3 and counter < conv_integer(data_length_temp) + 3) then 
			wr_fifo_flag1 <= '1';
		    data_fifo_21 <= "000" & data_in_temp_1(7 downto 0);
		    next_s <= outport_2;
		elsif(counter = conv_integer(data_length_temp) + 3) then 
			wr_fifo_flag1 <= '0';
			data_fifo_21 <= (others => '0');
			next_s <= idle;
		else
			data_fifo_21 <= (others => '0');
			wr_fifo_flag1 <= '0';
			next_s <= outport_2;
		end if;
		  
	when outport_3 => 
		wr_fifo_flag0 <= '0';
		wr_fifo_flag1 <= '0';
		data_fifo_20 <= (others => '0');
		data_fifo_21 <= (others => '0');
		if(counter = 2) then 
			wr_fifo_flag2 <= '1';
			data_fifo_23 <= data_length_temp;
			next_s <= outport_3;
		elsif(counter >= 3 and counter < conv_integer(data_length_temp) + 3) then 
			wr_fifo_flag2 <= '1';
			data_fifo_23 <= "000" & data_in_temp_1(7 downto 0);
			next_s <= outport_3;
		elsif(counter = conv_integer(data_length_temp) + 3) then 
			wr_fifo_flag2 <= '0';
			data_fifo_23 <= (others => '0');
			next_s <= idle;
		else
			data_fifo_23 <= (others => '0');
			wr_fifo_flag2 <= '0';
			next_s <= outport_3;
		end if;
		  
	when outport_br => 
		if(counter = 2) then 
			wr_fifo_flag0 <= '1';
			wr_fifo_flag1 <= '1';
			wr_fifo_flag2 <= '1';
			data_fifo_20 <= data_length_temp;
			data_fifo_21 <= data_length_temp;
			data_fifo_23 <= data_length_temp;
			next_s <= outport_br;
		elsif(counter >= 3 and counter < conv_integer(data_length_temp) + 3) then 
			wr_fifo_flag0 <= '1';
			wr_fifo_flag1 <= '1';
			wr_fifo_flag2 <= '1';
			data_fifo_20 <= "000" & data_in_temp_1(7 downto 0);
			data_fifo_21 <= "000" & data_in_temp_1(7 downto 0);
			data_fifo_23 <= "000" & data_in_temp_1(7 downto 0);
			next_s <= outport_br;
		elsif(counter = conv_integer(data_length_temp) + 3) then 
			wr_fifo_flag0 <= '0';
			wr_fifo_flag1 <= '0';
			wr_fifo_flag2 <= '0';
			data_fifo_20 <= (others => '0');
			data_fifo_21 <= (others => '0');
			data_fifo_23 <= (others => '0');
			next_s <= idle;
		else
			wr_fifo_flag0 <= '0';
			wr_fifo_flag1 <= '0';
			wr_fifo_flag2 <= '0';
			data_fifo_20 <= (others => '0');
			data_fifo_21 <= (others => '0');
			data_fifo_23 <= (others => '0');
			next_s <= outport_br;
		end if;
	  
	when outport_1_2 => 
		wr_fifo_flag2 <= '0';
		data_fifo_23 <= (others => '0');
		if(counter = 2) then 
			wr_fifo_flag0 <= '1';
			wr_fifo_flag1 <= '1';
			data_fifo_20 <= data_length_temp;
			data_fifo_21 <= data_length_temp;
			next_s <= outport_1_2;
		elsif(counter >= 3 and counter < conv_integer(data_length_temp) + 3) then
			wr_fifo_flag0 <= '1';
			wr_fifo_flag1 <= '1';
			data_fifo_20 <= "000" & data_in_temp_1(7 downto 0);
			data_fifo_21 <= "000" & data_in_temp_1(7 downto 0);
			next_s <= outport_1_2;
		elsif(counter = conv_integer(data_length_temp) + 3) then 
			wr_fifo_flag0 <= '0';
			wr_fifo_flag1 <= '0';
			data_fifo_20 <= (others => '0');
			data_fifo_21 <= (others => '0');
			next_s <= idle;
		else
			wr_fifo_flag0 <= '0';
			wr_fifo_flag1 <= '0';
			data_fifo_20 <= (others => '0');
			data_fifo_21 <= (others => '0');
			next_s <= outport_1_2;
	  end if;
	  
	when outport_1_3 => 
		wr_fifo_flag1 <= '0';
		data_fifo_21 <= (others => '0');
		if(counter = 2) then 
			wr_fifo_flag0 <= '1';
			wr_fifo_flag2 <= '1';
			data_fifo_20 <= data_length_temp;
			data_fifo_23 <= data_length_temp;
			next_s <= outport_1_3;
		elsif(counter >= 3 and counter < conv_integer(data_length_temp) + 3) then
			wr_fifo_flag0 <= '1';
			wr_fifo_flag2 <= '1';
			data_fifo_20 <= "000" & data_in_temp_1(7 downto 0);
			data_fifo_23 <= "000" & data_in_temp_1(7 downto 0);
			next_s <= outport_1_3;
		elsif(counter = conv_integer(data_length_temp) + 3) then 
			wr_fifo_flag0 <= '0';
			wr_fifo_flag2 <= '0';
			data_fifo_20 <= (others => '0');
			data_fifo_23 <= (others => '0');
			next_s <= idle;
		else
			wr_fifo_flag0 <= '0';
			wr_fifo_flag2 <= '0';
			data_fifo_20 <= (others => '0');
			data_fifo_23 <= (others => '0');
			next_s <= outport_1_3;
	  end if;
	  
	when outport_2_3 => 
		wr_fifo_flag0 <= '0';
		data_fifo_20 <= (others => '0');
		if(counter = 2) then 
			wr_fifo_flag1 <= '1';
			wr_fifo_flag2 <= '1';
			data_fifo_21 <= data_length_temp;
			data_fifo_23 <= data_length_temp;
			next_s <= outport_2_3;
		elsif(counter >= 3 and counter < conv_integer(data_length_temp) + 3) then
			wr_fifo_flag1 <= '1';
			wr_fifo_flag2 <= '1';
			data_fifo_21 <= "000" & data_in_temp_1(7 downto 0);
			data_fifo_23 <= "000" & data_in_temp_1(7 downto 0);
			next_s <= outport_2_3;
		elsif(counter = conv_integer(data_length_temp) + 3) then 
			wr_fifo_flag1 <= '0';
			wr_fifo_flag2 <= '0';
			data_fifo_21 <= (others => '0');
			data_fifo_23 <= (others => '0');
			next_s <= idle;
		else
			wr_fifo_flag1 <= '0';
			wr_fifo_flag2 <= '0';
			data_fifo_21 <= (others => '0');
			data_fifo_23 <= (others => '0');
			next_s <= outport_2_3;
		end if;
	  
	  

	when discard => 
		wr_fifo_flag0 <= '0';
		wr_fifo_flag1 <= '0';
		wr_fifo_flag2 <= '0';
		data_fifo_20 <= (others => '0');
		data_fifo_21 <= (others => '0');
		data_fifo_23 <= (others => '0');
		if(counter = 2) then 
			delete_temp <= "00" & data_length_temp;
			next_s <= discard;
		elsif(counter >= 3 and counter < conv_integer(data_length_temp) + 3) then 
			delete_temp <= data_in_temp_1;
			next_s <= discard;
		elsif(counter = conv_integer(data_length_temp) + 3) then 
			next_s <= idle;
		else
			next_s <= discard;
		end if;

  end case;
end process;

end crossbar_input_block_2_arch;




