-- Description: Captures the pixels coming from the OV7670 camera and Stores them in block RAM
-- RGB mode replaced by YUV, Y-channel only 

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--use work.matrix.all;

entity ov7670_capture is
	Port ( pclk  : in   std_logic;
				 vsync : in   std_logic;
				 href  : in   std_logic;
				 din    : in   std_logic_vector (7 downto 0);
				 addr  : out  std_logic_vector (18 downto 0);
				 dout  : out  std_logic_vector (7 downto 0);
				 we    : out  std_logic);
end ov7670_capture;

architecture Behavioral of ov7670_capture is
	signal address : std_logic_vector(18 downto 0) := (others => '0');
	signal state    : std_logic := '0';

begin
	addr <= address;
	process(pclk)
	begin
		if rising_edge(pclk) then
			if vsync = '1' then 
				address <= (others => '0');
				we <= '0';
				state <= '0';
			else
				if state = '1' and href = '1' then
					address <= std_logic_vector(unsigned(address)+1);
					we <= '0';
					state <= '0';
				else
					dout <= din; 
					we <= '1';
					state <= '1';
				end if; -- state
			end if;
		end if; -- edge
	end process;

end Behavioral;