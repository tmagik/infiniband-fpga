LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

library work;
use work.physlayer_lib.all;
use work.ltsmdefinitions.all;

ENTITY TSDetector_TB IS
END TSDetector_TB;

ARCHITECTURE behavior OF TSDetector_TB IS 

	-- Component Declaration
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

	-- Inputs
	SIGNAL Clock :  std_logic := '0';
	SIGNAL PowerOnReset : std_logic := '1';
	SIGNAL TxCmd : TxCmdType := Disabled;
	SIGNAL RxCmd : RxCmdType := Disabled;
	
	-- Outputs 
	signal TS1TxData : Symbol_8b10b;
	signal TS2TxData : Symbol_8b10b;
	signal TxData    : Symbol_8b10b;
	signal RecvdTS1  : boolean;
	signal RecvdTS2  : boolean;
BEGIN

	TxSel : process ( TxCmd, TS1TxData, TS2TxData ) is
	begin
		case TxCmd is
		when SendTS1 =>
			TxData <= TS1TxData;
		when SendTS2 =>
			TxData <= TS2TxData;
		when Others =>
			TxData <= (K, 0, 0);
		end case;
	end process;

	-- Component Instantiation
	TS1Writer : TSWriter 
	generic map
	(
		TSNumber => 1
	)
	PORT MAP
	(
		Clock        => Clock,
		PowerOnReset => PowerOnReset,
		TxCmd        => TxCmd,
		TxData       => TS1TxData
	);
	
	TS2Writer : TSWriter 
	generic map
	(
		TSNumber => 2
	)
	PORT MAP
	(
		Clock        => Clock,
		PowerOnReset => PowerOnReset,
		TxCmd        => TxCmd,
		TxData       => TS2TxData
	);

	TS1Detector : TSDetector
	generic map
	(
		TSNumber => 1
	)
	PORT MAP
	(
		Clock        => Clock,
		PowerOnReset => PowerOnReset,
		RxCmd        => RxCmd,
		RxData       => TxData,
		RecvdTS      => RecvdTS1
	);
	
	TS2Detector : TSDetector
	generic map
	(
		TSNumber => 2
	)
	PORT MAP
	(
		Clock        => Clock,
		PowerOnReset => PowerOnReset,
		RxCmd        => RxCmd,
		RxData       => TxData,
		RecvdTS      => RecvdTS2
	);

	Signal_Process : Process
	begin
		PowerOnReset <= '1';
		wait for 100 ns;
		PowerOnReset <= '0';
		wait for 50 ns;
		TxCmd <= SendTS1;
		RxCmd <= WaitTS1;
		wait for 400 ns;
		TxCmd <= SendTS2;
		RxCmd <= WaitTS2;
		wait for 400 ns;
		TxCmd <= Disabled;
		RxCmd <= Disabled;
		wait for 100 ns;
	end process Signal_Process;

	Clock_Process : PROCESS
	BEGIN
		while true loop
			wait for 5 ns;
			Clock <= not clock;
		end loop;
	END PROCESS Clock_Process;
	--  End Test Bench 

END;
