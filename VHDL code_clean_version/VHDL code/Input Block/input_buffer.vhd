LIBRARY ieee;
USE ieee.std_logic_1164.all;
LIBRARY altera_mf;
USE altera_mf.all;

ENTITY input_buffer IS
	PORT
   (
	clock		: IN STD_LOGIC ;
	sclr		: IN STD_LOGIC ;
	data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
	wrreq		: IN STD_LOGIC ;
	rdreq		: IN STD_LOGIC ;
	full		: OUT STD_LOGIC;
	q		   : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
	empty		: OUT STD_LOGIC  
	);
END input_buffer;


ARCHITECTURE SYN OF input_buffer IS

	SIGNAL sub_wire0	: STD_LOGIC ;
	SIGNAL sub_wire1	: STD_LOGIC ;
	SIGNAL sub_wire2	: STD_LOGIC_VECTOR (7 DOWNTO 0);

	COMPONENT scfifo
	GENERIC (
		add_ram_output_register		: STRING;
		intended_device_family		: STRING;
		lpm_hint		: STRING;
		lpm_numwords		: NATURAL;
		lpm_showahead		: STRING;
		lpm_type		: STRING;
		lpm_width		: NATURAL;
		lpm_widthu		: NATURAL;
		overflow_checking		: STRING;
		underflow_checking		: STRING;
		use_eab		: STRING
	);
	PORT (
		clock	: IN STD_LOGIC ;
		data	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdreq	: IN STD_LOGIC ;
		sclr	: IN STD_LOGIC ;
		empty	: OUT STD_LOGIC ;
		full	: OUT STD_LOGIC ;
		q	: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		wrreq	: IN STD_LOGIC 
	);
	END COMPONENT;

BEGIN
	empty    <= sub_wire0;
	full    <= sub_wire1;
	q    <= sub_wire2(7 DOWNTO 0);

	scfifo_component : scfifo
	GENERIC MAP (
		add_ram_output_register => "OFF",
		intended_device_family => "Stratix IV",
		lpm_hint => "RAM_BLOCK_TYPE=M9K",
		lpm_numwords => 2048,
		lpm_showahead => "ON",
		lpm_type => "scfifo",
		lpm_width => 8,
		lpm_widthu => 11,
		overflow_checking => "ON",
		underflow_checking => "ON",
		use_eab => "ON"
	)
	PORT MAP (
		clock => clock,
		data => data,
		rdreq => rdreq,
		sclr => sclr,
		wrreq => wrreq,
		empty => sub_wire0,
		full => sub_wire1,
		q => sub_wire2
	);

END SYN;

