library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.LtsmDefinitions.all;

package PhysLayer_Lib is
	type symbol_type is ( K, D );

	type symbol_8b10b is 
	record
		k    : symbol_type;
		high : integer range 0 to 31;
		low  : integer range 0 to 7;
	end record;

	constant Symbol_COMMA : symbol_8b10b := ( K, 28, 5 );
	constant Symbol_SDP   : symbol_8b10b := ( K, 27, 7 );
	constant Symbol_SLP   : symbol_8b10b := ( K, 28, 2 );
	constant Symbol_EGP   : symbol_8b10b := ( K, 29, 7 );
	constant Symbol_EBP   : symbol_8b10b := ( K, 30, 7 );
	constant Symbol_PAD   : symbol_8b10b := ( K, 23, 7 );
	constant Symbol_SKP   : symbol_8b10b := ( K, 28, 0 );

	component Idle_LFSR is

		Port 
		(
			Clock        : in  STD_LOGIC;
			PowerOnReset : in  STD_LOGIC;
			TxData       : out symbol_8b10b
		);
	end component Idle_LFSR;
	
	component RocketIO_Wrapper is
		Port 
		( 
			REFCLK_P        : in  STD_LOGIC;
			REFCLK_N        : in  STD_LOGIC;
			GTXRESET        : in  STD_LOGIC;
			PLL_LOCK_DETECT : out STD_LOGIC;
			USR_CLK         : out STD_LOGIC;
			USR_CLK2        : out STD_LOGIC;
			TX_DATA         : in  symbol_8b10b;
			RX_DATA         : out symbol_8b10b;
			SYNC            : out STD_LOGIC_VECTOR (1 downto 0);
			RXN_IN          : in  STD_LOGIC_VECTOR (1 downto 0);
			RXP_IN          : in  STD_LOGIC_VECTOR (1 downto 0);
			TXN_OUT         : out STD_LOGIC_VECTOR (1 downto 0);
			TXP_OUT         : out STD_LOGIC_VECTOR (1 downto 0)
		);
	end component RocketIO_Wrapper;
	
	component LinkTrainingStateMachine is
		generic
		(
			ClockRate : natural := 100000000
		);
		Port 
		(
			-- Signal inputs
			Clock        : in  STD_LOGIC;
			PowerOnReset : in  STD_LOGIC;
			LinkPhyReset : in  STD_LOGIC;
			
			-- FSM inputs
			LinkPhyRecover : in STD_LOGIC;
			RecvdTS1       : in boolean;
			RecvdTS2       : in boolean;
			RecvdIdle      : in boolean;
			RxTrained      : in boolean;
			RxMajorError   : in boolean;
			LaneOrderError : in boolean;
			HeartbeatError : in boolean;
			
			-- FSM outputs
			RxCmd : out RxCmdType;
			TxCmd : out TxCmdType
		);
	end component LinkTrainingStateMachine;
	
	component TSWriter is
		generic
		(
			TSNumber : natural range 1 to 2 := 1
		);
		port 
		( 
			Clock        : in  STD_LOGIC;
			PowerOnReset : in  STD_LOGIC;
			TxCmd        : in  TxCmdType;
			TxData       : out Symbol_8b10b
		);
	end component TSWriter;

	component TSDetector is
		generic 
		(
			TSNumber : natural range 1 to 2 := 1
		);
		Port 
		( 
			Clock        : in  STD_LOGIC;
			PowerOnReset : in  STD_LOGIC;
			RxCmd        : in  RxCmdType;
			RxData       : in  Symbol_8b10b;
			RecvdTS      : out boolean
		);
	end component TSDetector;
	
	function e8b10b_to_vec( value : symbol_8b10b )
		return std_logic_vector;
	
	function vec_to_e8b10b( value : std_logic_vector(8 downto 0) )
		return symbol_8b10b;
		
end PhysLayer_Lib;

package body PhysLayer_Lib is
	function e8b10b_to_vec( value : symbol_8b10b )
		return std_logic_vector is
		variable rv : std_logic_vector(8 downto 0);
	begin
		if (value.k = K) then 
			RV(8) := '1';
		else
			RV(8) := '0';
		end if;
		
		rv(4 downto 0) := conv_std_logic_vector(value.high, 5);
		rv(7 downto 5) := conv_std_logic_vector(value.low, 3);
		
		return rv;
	end;
	
	function vec_to_e8b10b( value : std_logic_vector(8 downto 0) )
		return symbol_8b10b is
		variable rv : symbol_8b10b;
	begin
		if (value(8) = '1') then
			rv.k := K;
		else
			rv.k := D;
		end if;
		
		rv.high := conv_integer(value(4 downto 0));
		rv.low := conv_integer(value(7 downto 5));
		
		return rv;
	end;
	
	
end PhysLayer_Lib;