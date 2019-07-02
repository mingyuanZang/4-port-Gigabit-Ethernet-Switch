
library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use std.textio.all;

entity crc_check is
 port(
		clk            : in std_logic; -- system clock
    reset          : in std_logic; -- asynchronous reset
	 data_in 	 : in std_logic_vector(7 downto 0); -- input data.
	 preamble_and_sof : in std_logic_vector(63 downto 0);
    start_of_frame : in std_logic; -- arrival of the first byte.
    eof            : in std_logic;
    frame_length   : in std_logic_vector(10 downto 0);
	 full_ctrl : in std_logic;
	 length_fcs_result : out std_logic_vector(11 downto 0);
	 wrreq_length   : out std_logic
	  ); 
 end crc_check;

 architecture behavior of crc_check is

 signal crc_temp : std_logic_vector (31 downto 0):= (others => '0');
 signal count : std_logic_vector (3 downto 0):= (others => '0');
 SIGNAL preamble_count : integer := 0;
 SIGNAL temp : integer := 0;
 signal preamble_and_sof_temp : std_logic_vector(63 downto 0):= (others => '0');
 signal save_pream_sof : std_logic := '0';
 
 begin

 process(clk)
 begin
   if rising_edge(clk) then
    if (save_pream_sof = '1') then 
         preamble_count <= preamble_count + 1;
			   temp <= (preamble_count)*8;
	 elsif (preamble_count>=1 and preamble_count<=8) then
			temp <= (preamble_count)*8;
			preamble_count <= preamble_count + 1;
	 else
      	preamble_count <= 0;
      	temp  <= 0;
    end if;
  end if; 
end process;
 
 
 process(clk)
 begin
	 if(rising_edge(clk))then
		if (reset = '1') then 
			count <= (others => '0');
			crc_temp <= (others => '0');
		else
		 if (start_of_frame ='1') then
			 count <= (others => '0');
	
			 crc_temp(0) <= not data_in(7);
			 crc_temp(1) <= not data_in(6);
			 crc_temp(2) <= not data_in(5);
			 crc_temp(3) <= not data_in(4);
			 crc_temp(4) <= not data_in(3);
			 crc_temp(5) <= not data_in(2);
			 crc_temp(6) <= not data_in(1);
			 crc_temp(7) <= not data_in(0);
	
		 elsif (count < 3) then
		    preamble_and_sof_temp <= preamble_and_sof;
			 count <= count + 1;
			 
			 crc_temp(0) <= crc_temp(24) xor crc_temp(30) xor (not data_in(7));
			 crc_temp(1) <= crc_temp(24) xor crc_temp(25) xor crc_temp(30) xor crc_temp(31) xor (not data_in(6));
			 crc_temp(2) <= crc_temp(24) xor crc_temp(25) xor crc_temp(26) xor crc_temp(30) xor crc_temp(31) xor (not data_in(5));
			 crc_temp(3) <= crc_temp(25) xor crc_temp(26) xor crc_temp(27) xor crc_temp(31) xor not (data_in(4));
			 crc_temp(4) <= crc_temp(24) xor crc_temp(26) xor crc_temp(27) xor crc_temp(28) xor crc_temp(30) xor (not data_in(3));
			 crc_temp(5) <= crc_temp(24) xor crc_temp(25) xor crc_temp(27) xor crc_temp(28) xor crc_temp(29) xor crc_temp(30) xor crc_temp(31) xor (not data_in(2));
			 crc_temp(6) <= crc_temp(25) xor crc_temp(26) xor crc_temp(28) xor crc_temp(29) xor crc_temp(30) xor crc_temp(31) xor (not data_in(1));
			 crc_temp(7) <= crc_temp(24) xor crc_temp(26) xor crc_temp(27) xor crc_temp(29) xor crc_temp(31) xor (not data_in(0));
		 else
			 count <= count;
	 
			 crc_temp(0) <= crc_temp(24) xor crc_temp(30) xor data_in(7);
			 crc_temp(1) <= crc_temp(24) xor crc_temp(25) xor crc_temp(30) xor crc_temp(31) xor data_in(6);
			 crc_temp(2) <= crc_temp(24) xor crc_temp(25) xor crc_temp(26) xor crc_temp(30) xor crc_temp(31) xor data_in(5);
			 crc_temp(3) <= crc_temp(25) xor crc_temp(26) xor crc_temp(27) xor crc_temp(31) xor data_in(4);
			 crc_temp(4) <= crc_temp(24) xor crc_temp(26) xor crc_temp(27) xor crc_temp(28) xor crc_temp(30) xor data_in(3);
			 crc_temp(5) <= crc_temp(24) xor crc_temp(25) xor crc_temp(27) xor crc_temp(28) xor crc_temp(29) xor crc_temp(30) xor crc_temp(31) xor data_in(2);
			 crc_temp(6) <= crc_temp(25) xor crc_temp(26) xor crc_temp(28) xor crc_temp(29) xor crc_temp(30) xor crc_temp(31) xor data_in(1);
			 crc_temp(7) <= crc_temp(24) xor crc_temp(26) xor crc_temp(27) xor crc_temp(29) xor crc_temp(31) xor data_in(0);
		 end if;
	
		 if (start_of_frame='1') then
			 crc_temp(31 downto 8) <= (others => '0');
		 else		 
			 crc_temp(8) <= crc_temp(0) xor crc_temp(24) xor crc_temp(25) xor crc_temp(27) xor crc_temp(28);
			 crc_temp(9) <= crc_temp(1) xor crc_temp(25) xor crc_temp(26) xor crc_temp(28) xor crc_temp(29);
			 crc_temp(10) <= crc_temp(2) xor crc_temp(24) xor crc_temp(26) xor crc_temp(27) xor crc_temp(29);
			 crc_temp(11) <= crc_temp(3) xor crc_temp(24) xor crc_temp(25) xor crc_temp(27) xor crc_temp(28);
			 crc_temp(12) <= crc_temp(4) xor crc_temp(24) xor crc_temp(25) xor crc_temp(26) xor crc_temp(28) xor crc_temp(29) xor crc_temp(30);
			 crc_temp(13) <= crc_temp(5) xor crc_temp(25) xor crc_temp(26) xor crc_temp(27) xor crc_temp(29) xor crc_temp(30) xor crc_temp(31);
			 crc_temp(14) <= crc_temp(6) xor crc_temp(26) xor crc_temp(27) xor crc_temp(28) xor crc_temp(30) xor crc_temp(31);
			 crc_temp(15) <= crc_temp(7) xor crc_temp(27) xor crc_temp(28) xor crc_temp(29) xor crc_temp(31);
			 crc_temp(16) <= crc_temp(8) xor crc_temp(24) xor crc_temp(28) xor crc_temp(29);
			 crc_temp(17) <= crc_temp(9) xor crc_temp(25) xor crc_temp(29) xor crc_temp(30);
			 crc_temp(18) <= crc_temp(10) xor crc_temp(26) xor crc_temp(30) xor crc_temp(31);
			 crc_temp(19) <= crc_temp(11) xor crc_temp(27) xor crc_temp(31);
			 crc_temp(20) <= crc_temp(12) xor crc_temp(28);
			 crc_temp(21) <= crc_temp(13) xor crc_temp(29);
			 crc_temp(22) <= crc_temp(14) xor crc_temp(24);
			 crc_temp(23) <= crc_temp(15) xor crc_temp(24) xor crc_temp(25) xor crc_temp(30);
			 crc_temp(24) <= crc_temp(16) xor crc_temp(25) xor crc_temp(26) xor crc_temp(31);
			 crc_temp(25) <= crc_temp(17) xor crc_temp(26) xor crc_temp(27);
			 crc_temp(26) <= crc_temp(18) xor crc_temp(24) xor crc_temp(27) xor crc_temp(28) xor crc_temp(30);
			 crc_temp(27) <= crc_temp(19) xor crc_temp(25) xor crc_temp(28) xor crc_temp(29) xor crc_temp(31);
			 crc_temp(28) <= crc_temp(20) xor crc_temp(26) xor crc_temp(29) xor crc_temp(30);
			 crc_temp(29) <= crc_temp(21) xor crc_temp(27) xor crc_temp(30) xor crc_temp(31);
			 crc_temp(30) <= crc_temp(22) xor crc_temp(28) xor crc_temp(31);
			 crc_temp(31) <= crc_temp(23) xor crc_temp(29);				 
		 end if;
		 if (crc_temp = "11111111111111111111111111111111" and eof = '1') then
			save_pream_sof <= '1';
			crc_temp <= (others => '0');
		 else 
			save_pream_sof <= '0';

		 end if;
    end if;
	end if;
 end process;

 process (crc_temp, preamble_count, eof, frame_length, preamble_and_sof_temp, temp, full_ctrl)
  begin
	 if (full_ctrl = '0') then
		 if (crc_temp = "11111111111111111111111111111111" and eof = '1') then
       			length_fcs_result <= (frame_length) & '0';
			    wrreq_length <= '1';
  	    elsif (crc_temp /= "11111111111111111111111111111111" and eof = '1') then
			length_fcs_result <= (frame_length) & '1';
			wrreq_length <= '1';
		 elsif (preamble_count>=1 and preamble_count<=8) then
			  length_fcs_result <= preamble_and_sof_temp(temp+7 downto temp) & "0000";
			  wrreq_length <= '1';
		 else 
				length_fcs_result <= (others => '0');
				wrreq_length <= '0';
		 end if;

	 elsif (full_ctrl = '1') then
			length_fcs_result <= (frame_length) & '1';
			wrreq_length <= '1';
			
	 else 
			length_fcs_result <= (others => '0');
			wrreq_length <= '0';
	 end if;		 
		 
	end process;

end behavior;
