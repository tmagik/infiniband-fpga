library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ip_compatibility.all;

package uart_components is
	component xmitter is
	generic
	(
		clk_freq : natural := 156250000;
		baud     : natural := 115200
	);
	port ( CLK             : in  STD_LOGIC;
	       RESET           : in  STD_LOGIC;
	       TX_DATA         : in  STD_LOGIC_VECTOR (7 downto 0);
	       TX_INIT         : in  STD_LOGIC;
	       TX_DONE         : out STD_LOGIC;
	       TX              : out STD_LOGIC);
	end component;
	
	component receiver is
	generic
	(
		clk_freq : natural := 156250000;
		baud     : natural := 115200
	);
	Port ( CLK             : in  STD_LOGIC;
	       RESET           : in  STD_LOGIC;
	       RX              : in  STD_LOGIC;
	       RX_DATA         : out STD_LOGIC_VECTOR (7 downto 0);
	       RX_DONE         : out STD_LOGIC);
	end component;
	
	component baud_pulse_generator is
		generic 
		( 
			clk_freq : natural := 156250000;
			baud     : natural := 115200
		);
		port 
		( 
			CLK    : in  STD_LOGIC;
			RESET  : in  STD_LOGIC;
			BPULSE : out STD_LOGIC
		);
	end component baud_pulse_generator;
	
	component uart_fifo is
		generic ( ip_provider : ip_provider_t := xilinx );
		port 
		( 
			CLK      : in  std_logic;
			RESET    : in  std_logic;
			DATA_IN  : in  std_logic_vector (7 downto 0);
			DATA_OUT : out std_logic_vector (7 downto 0);
			RD_REQ   : in  std_logic;
			WR_REQ   : in  std_logic;
			EMPTY    : out std_logic;
			FULL     : out std_logic
		);
	end component;
	
	component UART is
	generic 
	( 
		fosc : natural := 156250000;
		baud : natural := 115200;
		ip_provider : ip_provider_t := xilinx
	);
	port 
	(
		CLK       : in  std_logic;
		RESET     : in  std_logic;
		TEST_MODE : in  std_logic := '0';
		RXD       : in  std_logic;
		TXD       : out std_logic;
		XMIT_REQ  : in  std_logic;
		RECV_REQ  : in  std_logic;
		RECV_FULL : out std_logic;
		XMIT_FULL : out std_logic;
		RECV_RDY  : out std_logic;
		XMIT_DATA : in  std_logic_vector(7 downto 0);
		RECV_DATA : out std_logic_vector(7 downto 0)
	);
	end component;
	
	component uart_fifo_xilinx IS
		port 
		(
			clk   : IN  std_logic;
			din   : IN  std_logic_vector(7 downto 0);
			rd_en : IN  std_logic;
			rst   : IN  std_logic;
			wr_en : IN  std_logic;
			dout  : OUT std_logic_vector(7 downto 0);
			empty : OUT std_logic;
			full  : OUT std_logic
		);
	end component;
	
	component uart_fifo_altera is
		port 
		(
			aclr  : in  std_logic;
			clock : in  std_logic;
			data  : in  std_logic_vector(7 downto 0);
			rdreq : in  std_logic;
			wrreq : in  std_logic;
			empty : out std_logic;
			full  : out std_logic;
			q     : out std_logic_vector(7 downto 0)
		);
	end component;
end uart_components;