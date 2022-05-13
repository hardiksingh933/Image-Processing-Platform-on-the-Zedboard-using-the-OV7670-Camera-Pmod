-- Description: Dummy module for future computer vision algoriths implementation 

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity core is
	Port ( 
				 clk25      : in  std_logic;
				 addr_mem0  : out std_logic_vector(18 downto 0);
				 addr_mem1  : out std_logic_vector(18 downto 0);
				 din : in  std_logic_vector(7 downto 0);
				 dout : out  std_logic_vector(3 downto 0);
				 we: out std_logic
			 );
end core;

architecture Behavioral of core is
	constant c_with       : natural := 640;
	constant c_height     : natural := 480;
	constant c_frame 			: natural := c_height * c_with;
	signal counter 				: unsigned(18 downto 0) := (others => '0');
	signal address_mem0		: unsigned(18 downto 0) := (others => '0');
	signal address_mem1		: unsigned(18 downto 0) := (others => '0');

begin
	addr_mem0 <= std_logic_vector(address_mem0);
	addr_mem1 <= std_logic_vector(address_mem1);
	we <='1';

	process(clk25)
	begin
		if rising_edge(clk25) then
			if counter >= c_frame then
				counter <= (others => '0');
				address_mem0 <= (others => '0');
				address_mem1 <= (others => '0');
				dout <= (others => '0');
			else
				-- normal image area
				-- generate addr for next clk cicle
				address_mem0 <= address_mem0 + 1;
				address_mem1 <= address_mem1 + 1;
				counter <= counter+1; 
				dout <= din(7 downto 4);
			end if; -- counter
		end if; -- edge
	end process;
end Behavioral;