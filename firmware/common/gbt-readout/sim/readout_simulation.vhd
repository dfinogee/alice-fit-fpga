--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:03:54 02/04/2017
-- Design Name:   
-- Module Name:   D:/DATA/ISE/FIT_GBT_kc705/FIT_GBT_project/testbench_ClkSync.vhd
-- Project Name:  FIT_GBT_kc705
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: RXDATA_CLKSync
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all ;

use work.all;
use work.fit_gbt_common_package.all;
use work.fit_gbt_board_package.all;
 
ENTITY testbench_readout IS
END testbench_readout;
 
ARCHITECTURE behavior OF testbench_readout IS 

   --clocks
	constant Sys_period : time := 3.125 ns;
	constant ipbus_clock_period : time := 33.333 ns;
	signal RESET : std_logic := '0';
	signal SYS_CLK : std_logic := '0';
	signal DATA_CLK : std_logic := '0';
	signal IPBUS_CLK : std_logic := '0';
	signal GBT_RxFrameClk : std_logic := '0';
	
	signal FSM_Clocks_signal : FSM_Clocks_type;


    --ip-bus read
    signal IPBUS_gen_rst : std_logic;
    signal IPBUS_gen_isrd : std_logic;
    signal IPBUS_gen_addr : std_logic_vector (11 downto 0);
    signal IPBUS_data_out : std_logic_vector (31 downto 0);
    signal IPBUS_ackn : std_logic;

 	--Outputs
	signal from_gbt_bank_prj_GBT_status : Type_GBT_status;
	
   signal Data_from_FITrd             : std_logic_vector(GBT_data_word_bitdepth-1 downto 0);
   signal IsData_from_FITrd        : STD_LOGIC;
   
   signal RxData_rxclk_from_GBT     : std_logic_vector(GBT_data_word_bitdepth-1 downto 0);
   signal IsRxData_rxclk_from_GBT    : STD_LOGIC;
	
   	
	constant testbench_CONTROL_REG_default : CONTROL_REGISTER_type :=
	(
		Data_Gen => (
			--usage_generator		=> use_TX_generator,
			usage_generator	=> use_MAIN_generator,
			
			trigger_resp_mask 	=> TRG_const_void,
			bunch_pattern 		=> x"10e0766f",
			bunch_freq 			=> x"00ff",
			bunch_freq_hboffset => x"001"
			),
			
		Trigger_Gen => (
			usage_generator		=> use_CONT_generator,
			--usage_generator	=> use_NO_generator
			Readout_command		 => idle,
			trigger_single_val 		=> x"00000000",
			trigger_pattern 		=> x"0000000080000000",
			trigger_cont_value 			=> TRG_const_Ph,
			bunch_freq 				=> x"0deb",
			bunch_freq_hboffset 	=> x"ddc"
			),
		
		RDH_data => (
			FEE_ID 					=> x"0001",	
			PAR 					=> x"ffff",
			DET_Field 				=> x"1234"
			),
			
		readout_bypass              => '0',
	    is_hb_response              => '1',
        trg_data_select             => x"00000010",

		n_BCID_delay 				=> x"01f",
		crutrg_delay_comp 			=> x"00f",
		max_data_payload			=> x"00f0",
		reset_orbc_synd 			=> '0',
		reset_drophit_counter 		=> '0',
		reset_gen_offset			=> '0',
		reset_gbt_rxerror			=> '0',
		reset_gbt					=> '0',
		reset_rxph_error			=> '0',
		strt_rdmode_lock			=> '0'
	);	
	signal  testbench_CONTROL_REG_dynamic : CONTROL_REGISTER_type := testbench_CONTROL_REG_default;



BEGIN

FSM_Clocks_signal.Reset <= RESET;
FSM_Clocks_signal.Data_Clk <= DATA_CLK;
FSM_Clocks_signal.System_Clk <= SYS_CLK;
FSM_Clocks_signal.System_Counter <= x"0";
FSM_Clocks_signal.IPBUS_Data_Clk <= IPBUS_CLK;

 
  
 
-- FIT GBT project =====================================
FitGbtPrg: entity work.FIT_GBT_project
	generic map(
		GENERATE_GBT_BANK	=> 0
	)
	
	Port map(
		RESET_I				=>	FSM_Clocks_signal.Reset,
		SysClk_I			=>	FSM_Clocks_signal.System_Clk,
		DataClk_I			=>	FSM_Clocks_signal.Data_Clk,
		MgtRefClk_I			=>	FSM_Clocks_signal.Data_Clk,
		RxDataClk_I			=>  GBT_RxFrameClk, -- 40MHz data clock in RX domain (loop back)
		GBT_RxFrameClk_O	=>  GBT_RxFrameClk,
		
		Board_data_I		=> board_data_test_const,
		Control_register_I	=> testbench_CONTROL_REG_dynamic,
		
		MGT_RX_P_I => '0',
		MGT_RX_N_I => '0',
		MGT_TX_P_O => open,
		MGT_TX_N_O => open,
		MGT_TX_dsbl_O		=>	open,
		
		RxData_rxclk_to_FITrd_I 	=> RxData_rxclk_from_GBT, --loop back data
		IsRxData_rxclk_to_FITrd_I	=> IsRxData_rxclk_from_GBT, --loop back data
		Data_from_FITrd_O 			=> Data_from_FITrd,
		IsData_from_FITrd_O			=> IsData_from_FITrd,
		Data_to_GBT_I 				=> Data_from_FITrd, --loop back data
		IsData_to_GBT_I				=> IsData_from_FITrd, --loop back data
		
		RxData_rxclk_from_GBT_O	 	=> RxData_rxclk_from_GBT,
		IsRxData_rxclk_from_GBT_O	=> IsRxData_rxclk_from_GBT,
		rx_ph320 => open,
		ph_error320 => open, 

		FIT_GBT_status_O 	=> open
		);		
-- =====================================================


-- system and data clocks ==============================	
Sys1_process :process
   variable was_reset : integer := 0;
   variable counter : integer := 0;
   begin
   
		if(was_reset < 8) then
			was_reset := was_reset + 1;
			RESET <= '1';
		else
			RESET <= '0';
		end if;
	
		SYS_CLK <= '0';
		wait for Sys_period/2;
		
		counter := counter + 1;
		if(counter <= 4) then DATA_CLK <= '0'; else  DATA_CLK <= '1'; end if;
		if(counter = 8) then counter := 0; end if;
		
		
		SYS_CLK <= '1';
		wait for Sys_period/2;
  end process;
-- =====================================================
   
-- ipbus clock =========================================	
Sys2_process :process
   variable was_reset : integer := 0;
   variable addr_count : integer := 0;
   variable rd_rate_count : integer := 0;
   variable read_start_delay : integer := 0;

   begin
	
	IPBUS_CLK <= '0';
    wait for ipbus_clock_period/2;

	
   if(was_reset < 2) then
       was_reset := was_reset + 1;
       IPBUS_gen_rst <= '1';
   else
       IPBUS_gen_rst <= '0';
   end if;

   if(rd_rate_count < 200) then
       rd_rate_count := rd_rate_count + 1;
    else
       rd_rate_count := 0;
   end if;
   
   if(read_start_delay < 100) then
       read_start_delay := read_start_delay + 1;
    else
       read_start_delay := 100;
   end if;
	   
   IPBUS_gen_addr <= std_logic_vector(to_unsigned(20, 12));

   if(rd_rate_count < 60) then
       addr_count := addr_count + 1;
	   --IPBUS_gen_addr <= std_logic_vector(to_unsigned(addr_count, 12));
	   
	   if(read_start_delay >= 100) then
			IPBUS_gen_isrd <= '1';
		else
			IPBUS_gen_isrd <= '0';
		end if;
    else
       addr_count := 0;
	   --IPBUS_gen_addr <= std_logic_vector(to_unsigned(addr_count, 12));
       IPBUS_gen_isrd <= '0';
   end if;

            
    IPBUS_CLK <= '1';
    wait for ipbus_clock_period/2;
    
  end process;
-- =====================================================




END;
