-- Description: Top level for the OV7670 camera project.
-- change clocks, add new cv_core module and new BRAM 

library IEEE;
use IEEE.std_logic_1164.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

entity ov7670_top is
	Port ( 
				 clk100_zed   : in    std_logic;
				 OV7670_SIOC  : out   std_logic;
				 OV7670_SIOD  : inout std_logic;
				 OV7670_RESET : out   std_logic;
				 OV7670_PWDN  : out   std_logic;
				 OV7670_VSYNC : in    std_logic;
				 OV7670_HREF  : in    std_logic;
				 OV7670_PCLK  : in    std_logic;
				 OV7670_XCLK  : out   std_logic;
				 OV7670_D     : in    std_logic_vector(7 downto 0);

				 LED          : out    std_logic_vector(7 downto 0);

				 vga_red      : out   std_logic_vector(3 downto 0);
				 vga_green    : out   std_logic_vector(3 downto 0);
				 vga_blue     : out   std_logic_vector(3 downto 0);
				 vga_hsync    : out   std_logic;
				 vga_vsync    : out   std_logic;

				 btn	 		    : in    std_logic
			 );
end ov7670_top;

architecture Behavioral of ov7670_top is
	
	component clk_wiz_0                        -- clock wizard: IP block used
		port
		(	clk_in1     : in    std_logic;	   -- from clk100zed (dedicated clock pin on PL)
			clk_out1	: out	std_logic;     -- 100 MHz for blk mem1 in/out, mem2 in, core
			clk_out2    : out	std_logic;	   -- 50 MHz for blk mem2 out, debounce, controller
			clk_out3	: out	std_logic;     -- 75 Mhz clock not needed
			clk_out4	: out	std_logic      -- 25 MHz for vga
		);
	end component;
	
	component debounce
		Port(
					clk : in std_logic;
					i : in std_logic;          
					o : out std_logic
				);
	end component;

	component ov7670_capture
		Port(
					pclk : in std_logic;
					vsync : in std_logic;
					href  : in std_logic;
					din     : in std_logic_vector(7 downto 0);          
					addr  : out std_logic_vector(18 downto 0);
					dout  : out std_logic_vector(7 downto 0);
					we    : out std_logic
				);
	end component;

	component blk_mem_gen_0                   -- Dual port BRAM: IP block used
		Port (
					 clka  : in  std_logic;
					 wea   : in  std_logic_vector(0 downto 0);
					 addra : in  std_logic_vector(18 downto 0);
					 dina  : in  std_logic_vector(7 downto 0);
					 clkb  : in  std_logic;
					 addrb : in  std_logic_vector(18 downto 0);
					 doutb : out std_logic_vector(7 downto 0)
				 );
	end component;

	component core
		Port(
					 clk25     : in std_logic;
					 addr_mem0  : out std_logic_vector(18 downto 0);
					 addr_mem1  : out std_logic_vector(18 downto 0);
					 din : in  std_logic_vector(7 downto 0);
					 dout : out  std_logic_vector(3 downto 0);
					 we: out std_logic
				);
	end component;

	component blk_mem_gen_1                   -- Dual port BRAM: IP block used
		Port (
					 clka  : in  std_logic;
					 wea   : in  std_logic_vector(0 downto 0);
					 addra : in  std_logic_vector(18 downto 0);
					 dina  : in  std_logic_vector(3 downto 0);
					 clkb  : in  std_logic;
					 addrb : in  std_logic_vector(18 downto 0);
					 doutb : out std_logic_vector(3 downto 0)
				 );
	end component;

	component vga
		Port(
					clk25     : in std_logic;
					vga_red   : out std_logic_vector(3 downto 0);
					vga_green : out std_logic_vector(3 downto 0);
					vga_blue  : out std_logic_vector(3 downto 0);
					vga_hsync : out std_logic;
					vga_vsync : out std_logic;
					frame_addr : out std_logic_vector(18 downto 0);
					frame_pixel : in  std_logic_vector(3 downto 0)
				);
	end component;

	component ov7670_controller
		Port(
					clk   : in    std_logic;    
					resend: in    std_logic;    
					config_finished : out std_logic;
					siod  : inout std_logic;      
					sioc  : out   std_logic;
					reset : out   std_logic;
					pwdn  : out   std_logic;
					xclk  : out   std_logic
				);
	end component;

	-- clocks
	signal clk100        : std_logic;
	signal clk75         : std_logic;
	signal clk25         : std_logic;
	signal clk50         : std_logic;
	-- debounce to controller
	signal resend          : std_logic;
	-- capture to mem_blk_0
	signal capture_addr    : std_logic_vector(18 downto 0);
	signal capture_data    : std_logic_vector(7 downto 0);
	signal capture_we      : std_logic_vector(0 downto 0);
	-- mem_blk_0 -> core -> mem_blk_1
	signal data_to_core		    : std_logic_vector(7 downto 0);
	signal data_from_core  	  : std_logic_vector(3 downto 0);
	signal addr_core_to_mem0  : std_logic_vector(18 downto 0);
	signal addr_core_to_mem1  : std_logic_vector(18 downto 0);
	signal we_core_to_mem1    : std_logic_vector(0 downto 0);
	-- mem_blk_1 to vga
	signal frame_addr : std_logic_vector(18 downto 0);
	signal frame_pixel : std_logic_vector(3 downto 0);
	-- controller to LED
	signal config_finished : std_logic;

begin

	led <= btn & "000000" & config_finished;
		
clkwiz : clk_wiz_0
		   port map ( 
		   -- Clock in ports
		   clk_in1 => clk100_zed,
		  -- Clock out ports  
		   clk_out1 => clk100,
		   clk_out2 => clk75,
		   clk_out3 => clk50,
		   clk_out4 => clk25
		 );

	idebounce: debounce
	port map(
						clk => clk50,
						i   => btn,
						o   => resend
					);


	icapture: ov7670_capture
	port map(
						pclk  => OV7670_PCLK,
						vsync => OV7670_VSYNC,
						href  => OV7670_HREF,
						din   => OV7670_D,
						addr  => capture_addr,
						dout  => capture_data,
						we    => capture_we(0)
					);

	fb1 : blk_mem_gen_0
	port map (
						 clka  => OV7670_PCLK,
						 wea   => capture_we,
						 addra => capture_addr,
						 dina  => capture_data,

						 clkb  => clk50, -- =core clk25x2 - latency
						 addrb => addr_core_to_mem0,
						 doutb => data_to_core 
					 );

	icore: core
	port map(
						clk25		=> clk25,
						addr_mem0		=> addr_core_to_mem0,
						addr_mem1	=> addr_core_to_mem1,
						din				=> data_to_core,
						dout			=> data_from_core,
						we				=> we_core_to_mem1(0)
					);

	fb2 : blk_mem_gen_1
	port map (
						 clka  => clk25,
						 wea   => we_core_to_mem1,
						 addra => addr_core_to_mem1,
						 dina  => data_from_core,

						 clkb  => clk50, -- =vga clk25x2 - latency
						 addrb => frame_addr,
						 doutb => frame_pixel
					 );      

	ivga : vga
	port map(
						clk25       => clk25,
						vga_red     => vga_red,
						vga_green   => vga_green,
						vga_blue    => vga_blue,
						vga_hsync   => vga_hsync,
						vga_vsync   => vga_vsync,
						frame_addr => frame_addr,
						frame_pixel => frame_pixel
					);

	controller: ov7670_controller
	port map(
						clk   => clk50,
						sioc  => ov7670_sioc,
						resend => resend,
						config_finished => config_finished,
						siod  => ov7670_siod,
						pwdn  => OV7670_PWDN,
						reset => OV7670_RESET,
						xclk  => OV7670_XCLK
					);

end Behavioral;