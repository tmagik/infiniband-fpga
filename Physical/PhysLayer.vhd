library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.PhysLayer_Lib.all;
use work.LtsmDefinitions.all;

entity PhysLayer is
	Generic
	(
		-- 10 kHz here to speed up delays in the sim.
		-- Naturally this will be higher for actual hardware.
		ClockRate : natural := 10000
	);
	Port
	( 
		REFCLK_P         : in  STD_LOGIC;
		REFCLK_N         : in  STD_LOGIC;
		POWER_ON_RESET   : in  STD_LOGIC;
		SYSCLK           : out STD_LOGIC;
		SYSRESET         : out STD_LOGIC;
		RXN_IN           : in  STD_LOGIC;
		RXP_IN           : in  STD_LOGIC;
		TXN_OUT          : out STD_LOGIC;
		TXP_OUT          : out STD_LOGIC;
		LINK_PHY_TX_DATA : in  symbol_8b10b;
		LINK_PHY_RX_DATA : out symbol_8b10b;
		LINK_PHY_RESET   : in  STD_LOGIC;
		LINK_PHY_RECOVER : in  STD_LOGIC;
		LINK_PHY_UP      : out STD_LOGIC
	);
end PhysLayer;

architecture Behavioral of PhysLayer is
	-- Buffered output signals
	signal sysclk_o   : std_logic;
	signal sysreset_o : std_logic;
	
	-- FSM Control signals
	signal RecvdTS1       : boolean;
	signal RecvdTS2       : boolean;
	signal RecvdIdle      : boolean;
	signal RxTrained      : boolean;
	signal RxMajorError   : boolean;
	-- Not used since we don't detect a lane order error.
	signal LaneOrderError : boolean := false; 	
	-- Not used since we don't implement high speed signaling/heartbeats
	signal HeartbeatError : boolean := false; 
	
	-- FSM output control signals
	signal RxCmd    : RxCmdType;
	signal TxCmd    : TxCmdType;
	signal IdleData : Symbol_8b10b;
	signal TS1Data  : Symbol_8b10b;
	signal TS2Data  : Symbol_8b10b;
	
	-- RocketIO Control Signals
	signal PllLockDetected : STD_LOGIC;
	signal RocketIO_RxData : symbol_8b10b;
	signal RocketIO_TxData : symbol_8b10b;
	signal RocketIO_Sync   : STD_LOGIC_VECTOR (1 downto 0);
	
	-- Various state registers
	signal TS1_State : natural;
begin
	SYSCLK <= sysclk_o;
	SYSRESET <= sysreset_o;
	
	-- Hold reset high until the PLL locks.
	sysreset_o <= POWER_ON_RESET or not PllLockDetected;
	
	LINK_PHY_UP <= '1' when (TxCmd = Enabled) and (RxCmd = Enabled) else '0';
	
	-- The only error we currently detect is when RocketIO loses
	-- synchronization.
	RxMajorError <= RocketIO_Sync(1) = '1';
	RxTrained    <= RocketIO_Sync(1) = '0';

	-- Component declarations
	ltsm_i : LinkTrainingStateMachine
	generic map
	(
		ClockRate => ClockRate
	)
	port map
	(
		Clock          => sysclk_o,
		PowerOnReset   => sysreset_o,
		LinkPhyReset   => LINK_PHY_RESET,
		LinkPhyRecover => LINK_PHY_RECOVER,
		RecvdTS1       => RecvdTS1,
		RecvdTS2       => RecvdTS2,
		RecvdIdle      => RecvdIdle,
		RxTrained      => RxTrained,
		RxMajorError   => RxMajorError,
		LaneOrderError => LaneOrderError,
		HeartbeatError => HeartbeatError,
		RxCmd          => RxCmd, 
		TxCmd          => TxCmd
	);

	lfsr_i : Idle_LFSR
	port map
	(
		Clock        => sysclk_o, 
		PowerOnReset => sysreset_o,
		TxData       => IdleData
	);
	
	ts1writer_i : TSWriter
	generic map
	(
		TSNumber => 1
	)
	port map
	(
			Clock => sysclk_o,
			PowerOnReset => sysreset_o,
			TxCmd => TxCmd, 
			TxData => TS1Data
	);
	
	ts2writer_i : TSWriter
	generic map
	(
		TSNumber => 2
	)
	port map
	(
			Clock => sysclk_o,
			PowerOnReset => sysreset_o,
			TxCmd => TxCmd, 
			TxData => TS2Data
	);
	
	ts1detector_i : TSDetector
	generic map
	(
		TSNumber => 1
	)
	PORT MAP
	(
		Clock        => sysclk_o,
		PowerOnReset => sysreset_o,
		RxCmd        => RxCmd,
		RxData       => RocketIO_RxData,
		RecvdTS      => RecvdTS1
	);
	
	ts2detector_i : TSDetector
	generic map
	(
		TSNumber => 2
	)
	PORT MAP
	(
		Clock        => sysclk_o,
		PowerOnReset => sysreset_o,
		RxCmd        => RxCmd,
		RxData       => RocketIO_RxData,
		RecvdTS      => RecvdTS2
	);
	
	rocketio_i : RocketIO_Wrapper
	port map
	(
		REFCLK_P        => REFCLK_P,
		REFCLK_N        => REFCLK_N,
		GTXRESET        => POWER_ON_RESET,
		PLL_LOCK_DETECT => PllLockDetected,
		USR_CLK         => open,
		USR_CLK2        => sysclk_o,
		TX_DATA         => RocketIO_TxData,
		RX_DATA         => RocketIO_RxData,
		SYNC            => RocketIO_Sync,
		RXN_IN          => RXN_IN,
		RXP_IN          => RXP_IN, 
		TXN_OUT         => TXN_OUT, 
		TXP_OUT         => TXP_OUT
	);
	
	RxDataProc : process ( RxCmd, RocketIO_RxData ) is
	begin
		if ( RxCmd = Enabled ) then
			LINK_PHY_RX_DATA <= RocketIO_RxData;
		else
			LINK_PHY_RX_DATA <= (K, 0, 0);
		end if;
	end process RxDataProc;
	
	TxDataProc : process ( TxCmd, LINK_PHY_TX_DATA, TS1Data, TS2Data, IdleData ) is
	begin
		case TxCmd is
		when Enabled =>
			if ( LINK_PHY_TX_DATA /= (K, 0, 0) ) then
				RocketIO_TxData <= LINK_PHY_TX_DATA;
			else
				RocketIO_TxData <= IdleData;
			end if;
		when SendTS1 =>
			RocketIO_TxData <= TS1Data;
		when SendTS2 => 
			RocketIO_TxData <= TS2Data;
		when Disabled =>
			RocketIO_TxData <= (D, 0, 0);
		when others =>
			RocketIO_TxData <= IdleData;
		end case;
  end process TxDataProc;

  IdleDetectProc : process ( sysclk_o ) is
  begin
    if ( POWER_ON_RESET = '1' ) then
      RecvdIdle <= false;
    elsif ( rising_edge( sysclk_o ) ) then
      if ( RxCmd /= WaitIdle ) then
        RecvdIdle <= false;
      else
        RecvdIdle <= RocketIO_RxData /= Symbol_COMMA and
                     RocketIO_RxData /= Symbol_SKP   and
                     RocketIO_RxData /= ( D, 10, 2 ) and
                     RocketIO_RxData /= ( D,  5, 2 ) and
                     RocketIO_RxData /= ( D,  0, 0 );
      end if;
    end if;
  end process IdleDetectProc;

end Behavioral;

