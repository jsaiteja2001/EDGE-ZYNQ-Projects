----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:27:22 12/26/2018 
-- Design Name: 
-- Module Name:    LCD - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity LCD is
    Port ( 	clk 	: in  STD_LOGIC;
         	lcd_e  : out std_logic;   ----enable control
				lcd_rs : out std_logic;   ----data or command control
				data   : out std_logic_vector(7 downto 0);
				x0,x1,x2,x3,x4: in std_logic_vector(3 downto 0); 
				y0,y1,y2,y3,y4: in std_logic_vector(3 downto 0); 
				z0,z1,z2,z3,z4: in std_logic_vector(3 downto 0)); 
end LCD;

architecture Behavioral of LCD is


type arr1 is array (1 to 6) of std_logic_vector(7 downto 0); 
constant datas : arr1 :=    (X"38",X"0c",X"06",X"01",X"81",X"58"); --command and data to display                                              


begin
process(clk)
variable i : integer := 0;
variable j : integer := 1;
begin

if clk'event and clk = '1' then
	if i <= 1000000 then
		i := i + 1;
		lcd_e <= '1';
		if j < 7 then
			data <= datas(j)(7 downto 0);
		elsif j = 7 then
			data <= "0011" & x4;
		elsif j = 8 then
			data <= "0011" & x3;
		elsif j = 9 then
			data <= "0011" & x2;
		elsif j = 10 then
			data <= "0011" & x1;
		elsif j = 11 then
			data <= "0011" & x0;
		elsif j = 12 then
			data <=X"c1" ;
		elsif j = 13 then
			data <=X"59" ;			
		elsif j = 14 then
			data <= "0011" & y4;
		elsif j = 15 then
			data <= "0011" & y3;
		elsif j = 16 then
			data <= "0011" & y2;
		elsif j = 17 then
			data <= "0011" & y1;
		elsif j = 18 then
			data <= "0011" & y0;	
		elsif j = 19 then
			data <= x"20";	
			elsif j = 20 then
			data <=X"5a" ;
		elsif j = 21 then
			data <= "0011" & z4;
		elsif j = 22 then
			data <= "0011" & z3;
		elsif j = 23 then
			data <= "0011" & z2;
		elsif j = 24 then
			data <= "0011" & z1;
		elsif j = 25 then
			data <= "0011" & z0;
		end if;
	elsif i > 1000000 and i < 2000000 then
		i := i + 1;
		lcd_e <= '0';
	elsif i = 2000000 then
		j := j + 1;
		i := 0;
	end if;
	if j <= 5  then
		lcd_rs <= '0';    ---command signal
	elsif j > 5 and j <= 11 then
		lcd_rs <= '1';   ----data signal
		elsif  j= 12 then
		lcd_rs <= '0';
   elsif j > 12 and j <= 25 then
		lcd_rs <= '1';
			end if;

	if j = 26 then  ---repeated display of data
		j := 5;
	end if;
end if;

end process;
end Behavioral;





