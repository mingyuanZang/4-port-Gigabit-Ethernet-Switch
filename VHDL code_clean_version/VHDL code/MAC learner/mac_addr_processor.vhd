library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mac_addr_processor is
  port ( 
	clk            : in std_logic; -- system clock
    reset          : in std_logic; -- asynchronous reset
    mac_req_0      : in std_logic;
    mac_req_1      : in std_logic;
    mac_req_2      : in std_logic;
    mac_req_3      : in std_logic;
    mac_addr_0 	 : in std_logic_vector(95 downto 0); -- 47 downto 0 is dest addr, 95 downto 48 is src addr.
	mac_addr_1 	 : in std_logic_vector(95 downto 0); -- 47 downto 0 is dest addr, 95 downto 48 is src addr.
	mac_addr_2  	 : in std_logic_vector(95 downto 0); -- 47 downto 0 is dest addr, 95 downto 48 is src addr.
	mac_addr_3 	 : in std_logic_vector(95 downto 0); -- 47 downto 0 is dest addr, 95 downto 48 is src addr.
	data_from_ram  : in std_logic_vector(49 downto 0);
	ctrl_flag_0    : out std_logic_vector(3 downto 0) := "0000"; --result from mac learning module 
	ctrl_flag_1    : out std_logic_vector(3 downto 0) := "0000"; --result from mac learning module 
	ctrl_flag_2    : out std_logic_vector(3 downto 0) := "0000"; --result from mac learning module 
	ctrl_flag_3    : out std_logic_vector(3 downto 0) := "0000"; --result from mac learning module 
	hash_addr      : out std_logic_vector(11 downto 0); --sent to RAM
	data_to_ram    : out std_logic_vector(49 downto 0);
	wr_en          : out std_logic;
	rd_en          : out std_logic
	 );
end mac_addr_processor;

architecture mac_addr_processor_arch of mac_addr_processor is

signal counter : integer;
signal mac_addr_f : std_logic_vector(2 downto 0);
signal addr_temp : std_logic_vector(47 downto 0) := (others => '0');

type state_type is (idle,mac_learn, mac_lookup,serve_port_0,serve_port_1,serve_port_2,serve_port_3,broad_port_0,broad_port_1,broad_port_2,broad_port_3);  --type of state machine.
signal current_s,next_s: state_type;

begin

process(clk) 
begin 
  if rising_edge(clk) then
    if(reset = '1') then
		counter <= 0;
		hash_addr <= (others => '0');
		data_to_ram <= (others => '0');
		ctrl_flag_0 <= "0000";
		ctrl_flag_1 <= "0000";
		ctrl_flag_2 <= "0000";
		ctrl_flag_3 <= "0000";
	else
		current_s <= next_s;
		if (next_s = idle) then 
			counter <= 0;
			data_to_ram <= (others => '0');
			if(mac_req_0 = '1') then
				mac_addr_f <= "100";
			elsif(mac_req_1 = '1') then
			    mac_addr_f <= "101";
			elsif(mac_req_2 = '1') then
				mac_addr_f <= "110";
			elsif(mac_req_3 = '1') then
				mac_addr_f <= "111";
			else
				mac_addr_f <= (others => '0');
			end if;
		elsif (next_s = mac_learn) then
			counter <= counter + 1; 
			if(mac_addr_f = "100") then
				hash_addr <= mac_addr_0(95 downto 84) xor mac_addr_0(83 downto 72) xor mac_addr_0(71 downto 60) xor mac_addr_0(59 downto 48);
				data_to_ram <= mac_addr_0(95 downto 48) & "00";
				addr_temp <= mac_addr_0(47 downto  0);
			elsif(mac_addr_f = "101") then
				hash_addr <= mac_addr_1(95 downto 84) xor mac_addr_1(83 downto 72) xor mac_addr_1(71 downto 60) xor mac_addr_1(59 downto 48);
				data_to_ram <= mac_addr_1(95 downto 48) & "01";
				addr_temp <= mac_addr_1(47 downto  0);
			elsif(mac_addr_f = "110") then
				hash_addr <= mac_addr_2(95 downto 84) xor mac_addr_2(83 downto 72) xor mac_addr_2(71 downto 60) xor mac_addr_2(59 downto 48);
				data_to_ram <= mac_addr_2(95 downto 48) & "10";
				addr_temp <= mac_addr_2(47 downto  0);
			elsif(mac_addr_f = "111") then
				hash_addr <= mac_addr_3(95 downto 84) xor mac_addr_3(83 downto 72) xor mac_addr_3(71 downto 60) xor mac_addr_3(59 downto 48);
				data_to_ram <= mac_addr_3(95 downto 48) & "11";
				addr_temp <= mac_addr_3(47 downto  0);
			end if;
		elsif(next_s = mac_lookup) then
			if(mac_addr_f = "100") then
			   hash_addr <= mac_addr_0(47 downto 36) xor mac_addr_0(35 downto 24) xor mac_addr_0(23 downto 12) xor mac_addr_0(11 downto 0);
			elsif(mac_addr_f = "101") then	
				hash_addr <= mac_addr_1(47 downto 36) xor mac_addr_1(35 downto 24) xor mac_addr_1(23 downto 12) xor mac_addr_1(11 downto 0);
			elsif(mac_addr_f = "110") then	  
				hash_addr <= mac_addr_2(47 downto 36) xor mac_addr_2(35 downto 24) xor mac_addr_2(23 downto 12) xor mac_addr_2(11 downto 0);
			elsif(mac_addr_f = "111") then	
				hash_addr <= mac_addr_3(47 downto 36) xor mac_addr_3(35 downto 24) xor mac_addr_3(23 downto 12) xor mac_addr_3(11 downto 0);
			end if;
				counter <= counter + 1;  	
		elsif(next_s = serve_port_0)then
		    counter <= counter + 1; 
		    ctrl_flag_0 <= '0' & data_from_ram(1 downto 0) & '1'; --add 1 at the end to identify it for the later crossbar 
	    elsif(next_s = serve_port_1)then
		    counter <= counter + 1; 
		    ctrl_flag_1 <= '0' & data_from_ram(1 downto 0) & '1'; --add 1 at the end to identify it for the later crossbar 
	    elsif(next_s = serve_port_2)then
		    counter <= counter + 1; 
		    ctrl_flag_2 <= '0' & data_from_ram(1 downto 0) & '1'; --add 1 at the end to identify it for the later crossbar  
	    elsif(next_s = serve_port_3)then
		    counter <= counter + 1; 
		    ctrl_flag_3 <= '0' & data_from_ram(1 downto 0) & '1'; --add 1 at the end to identify it for the later crossbar 
	    elsif(next_s = broad_port_0) then
		    counter <= counter + 1; 
		    ctrl_flag_0 <= "1111";
	    elsif(next_s = broad_port_1) then
		    counter <= counter + 1; 
		    ctrl_flag_1 <= "1111";
	    elsif(next_s = broad_port_2) then
		    counter <= counter + 1; 
		    ctrl_flag_2 <= "1111";
	    elsif(next_s = broad_port_3) then
	        counter <= counter + 1; 
		    ctrl_flag_3 <= "1111"; 
		else
			counter <= 0;
	    end if;
    end if;
  end if; 
end process;

process (current_s, counter, data_from_ram, addr_temp, mac_addr_f)
begin
  
case current_s is
	    when idle => 
			rd_en <= '0';
			wr_en <= '0';
			if(mac_addr_f = "100" or mac_addr_f = "101" or mac_addr_f = "110" or mac_addr_f = "111") then
			    next_s <= mac_learn;
			else
			    next_s <= idle;
			end if;
		
		
		when mac_learn => 
			rd_en <= '0';
			if(counter = 1) then
			    wr_en <= '1';
			    next_s <= mac_lookup;
		    else
				wr_en <= '0';
				next_s <= mac_learn;
			end if;
	  
	    when mac_lookup =>
			wr_en <= '0';
			if(counter = 2) then
			    rd_en <= '1';
			    next_s <= mac_lookup;
			elsif(counter = 3) then
				rd_en <= '0';
			    if(data_from_ram(49 downto 2) = addr_temp) then
					if(mac_addr_f = "100") then
					    next_s <= serve_port_0;
					elsif(mac_addr_f = "101") then
					    next_s <= serve_port_1;
					elsif(mac_addr_f = "110") then
					    next_s <= serve_port_2;
					elsif(mac_addr_f = "111") then
					    next_s <= serve_port_3;
					else
						rd_en <= '0';
						next_s <= idle; 
					end if;
				else
					if(mac_addr_f = "100") then
						next_s <= broad_port_0;
					elsif(mac_addr_f = "101") then
					    next_s <= broad_port_1;
					elsif(mac_addr_f = "110") then 
						next_s <= broad_port_2;  
					elsif(mac_addr_f = "111") then  
						next_s <= broad_port_3; 
					else
					    rd_en <= '0';
						next_s <= idle;
					end if;
				end if;
			else
				rd_en <= '0';
				next_s <= idle;
			end if;
		
		when serve_port_0 =>
			rd_en <= '0';
			wr_en <= '0';
			next_s <= idle;
		 
		when serve_port_1 =>
			rd_en <= '0';
			wr_en <= '0';
			next_s <= idle;
		 
		when serve_port_2 =>
			rd_en <= '0';
			wr_en <= '0';
			next_s <= idle;
			 
		when serve_port_3 =>
			rd_en <= '0';
			wr_en <= '0';
			next_s <= idle;
		
		when broad_port_0 =>
			rd_en <= '0';
			wr_en <= '0';
			next_s <= idle;
			 
		when broad_port_1 =>
			rd_en <= '0';
			wr_en <= '0';
			next_s <= idle;     
	  
	    when broad_port_2 =>
		    rd_en <= '0';
			wr_en <= '0';
			next_s <= idle;
		
		when broad_port_3 =>
			rd_en <= '0';
			wr_en <= '0';
			next_s <= idle;
  
end case; 
end process;

end mac_addr_processor_arch;
