-- Description: Register settings for initializing the OV7670 Caamera
-- RGB mode replaced by YUV, Y-channel only

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ov7670_registers is
	Port ( clk      : in  std_logic;
				 resend   : in  std_logic;
				 advance  : in  std_logic;
				 command  : out  std_logic_vector(15 downto 0);
				 finished : out  std_logic);
end ov7670_registers;

architecture Behavioral of ov7670_registers is
	signal sreg   : std_logic_vector(15 downto 0);
	signal address : std_logic_vector(7 downto 0) := (others => '0');
	signal rgb : std_logic_vector(15 downto 0);
begin
	command <= sreg;
	with sreg select finished  <=
	'1' when x"FFFF",
	'0' when others;

	process(clk)
	begin
		if rising_edge(clk) then
			if resend = '1' then 
				address <= (others => '0');
			elsif advance = '1' then
				address <= std_logic_vector(unsigned(address)+1);
			end if;

			case address is                    --                                                         reg_location (address) | data being sent into that location
				when x"00" => sreg <= x"1280"; -- COM7   Reset                                                         0001_0010 | 1000_0000
				when x"01" => sreg <= x"1280"; -- COM7   Reset                                                         0001_0010 | 1000_0000
				when x"02" => sreg <= x"1200"; -- COM7   Size & YUV output                                             0001_0010 | 0000_0000
            --  when x"03" => sreg <= x"1180"; -- CLKRC  Prescaler   x"11_??" !!                                       1011_1011 | 1000_0000
				when x"03" => sreg <= x"1100"; -- CLKRC  Prescaler - Fin/(1+1)                                         1011_1011 | 0000_0000
				when x"04" => sreg <= x"0C00"; -- COM3   Lots of stuff, enable scaling, all others off                 1011_1100 | 0000_0000
				when x"05" => sreg <= x"3E00"; -- COM14  PCLK scaling off                                              0011_1110 | 0000_0000

				when x"06" => sreg <= x"8C00"; -- YUV Set (4:2:2) format                                               1111_1100 | 0000_0000
				when x"07" => sreg <= x"0400"; -- COM1   no CCIR601                                                    0000_0100 | 0000_0000
				when x"08" => sreg <= x"4010"; -- COM15  Full 0-255 output, YUV (4:2:2)                                0100_0000 | 0001_0000
		    --  when x"09" => sreg <= x"3a04"; -- TSLB   Set UV ordering,  do not auto-reset window
				when x"09" => sreg <= x"3a14"; -- TSLB   Set UV ordering,  do not auto-reset window                    0011_1010 | 0001_1110
				when x"0A" => sreg <= x"1438"; -- COM9   AGC Celling                                                   0000_1010 | 0011_1000
				when x"11" => sreg <= x"589e"; -- MTXS   Matrix sign and auto contrast                                 0101_1000 | 1001_1110
			--  when x"12" => sreg <= x"3dc0"; -- COM13  Turn on GAMMA and UV Auto adjust                     
				when x"12" => sreg <= x"3d88"; -- COM13  Turn on GAMMA and UV Auto adjust                              0011_1101 | 1000_1000
				when x"13" => sreg <= x"1100"; -- CLKRC  Prescaler - Fin/(1+1)                                         0001_0001 | 0000_0000

				when x"14" => sreg <= x"1711"; -- HSTART HREF start (high 8 bits)                                      0001_0111 | 0001_0001
				when x"15" => sreg <= x"1861"; -- HSTOP  HREF stop (high 8 bits)                                       0001_1000 | 0110_0001
				when x"16" => sreg <= x"32A4"; -- HREF   Edge offset and low 3 bits of HSTART and HSTOP                0011_1010 | 0000_0100

				when x"17" => sreg <= x"1903"; -- VSTART VSYNC start (high 8 bits)                                     0001_1001 | 0000_0011
				when x"18" => sreg <= x"1A7b"; -- VSTOP  VSYNC stop (high 8 bits)                                      0001_1010 | 0111_1011
				when x"19" => sreg <= x"030a"; -- VREF   VSYNC low two bits                                            0000_0011 | 0000_1010
				when others => sreg <= x"ffff";-- Configuration Over !!                                                1111_1111 | 1111_1111
			end case;
		end if;
	end process;
end Behavioral;