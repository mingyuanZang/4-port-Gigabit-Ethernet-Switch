LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY lookup_RAM IS
	PORT
	(
	clock		: IN STD_LOGIC  := '1';
	address	: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
	data		: IN STD_LOGIC_VECTOR (49 DOWNTO 0);
	wren		: IN STD_LOGIC ;
	rden		: IN STD_LOGIC  := '1';
	q		   : OUT STD_LOGIC_VECTOR (49 DOWNTO 0)
	);
END lookup_RAM;

ARCHITECTURE SYN OF lookup_ram IS

	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (49 DOWNTO 0);

BEGIN
	q    <= sub_wire0(49 DOWNTO 0);
	altsyncram_component : altsyncram
	GENERIC MAP (
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		intended_device_family => "Stratix IV",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		numwords_a => 4096,
		operation_mode => "SINGLE_PORT",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "CLOCK0",
		power_up_uninitialized => "FALSE",
		read_during_write_mode_port_a => "NEW_DATA_NO_NBE_READ",
		widthad_a => 12,
		width_a => 50,
		width_byteena_a => 1
	)
	PORT MAP (
		address_a => address,
		clock0 => clock,
		data_a => data,
		wren_a => wren,
		rden_a => rden,
		q_a => sub_wire0
	);

END SYN;
