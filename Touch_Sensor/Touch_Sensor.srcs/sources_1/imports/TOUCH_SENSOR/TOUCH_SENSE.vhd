


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
  
entity TOUCH is
Port ( 
		TOUCH_IN : in STD_LOGIC_VECTOR (3 downto 0);  
		TOUCH_OUT : out STD_LOGIC_VECTOR (3 downto 0)); --LED
end TOUCH;
  
architecture Behavioral of TOUCH is
  
begin
  

process(TOUCH_IN)
begin
  
case TOUCH_IN is
when "0001" =>
TOUCH_OUT <= "0001";   
when "0011" =>
TOUCH_OUT <= "0011";   
when "0010" =>
TOUCH_OUT <= "0010";  
when "0110" =>
TOUCH_OUT <= "0110";    
when "0100" =>
TOUCH_OUT <= "0100";   
when "1100" =>
TOUCH_OUT <= "1100";  
when "1000" =>
TOUCH_OUT <= "1000";  
when others =>
TOUCH_OUT <= "0000";  
end case;

end process;
  
end Behavioral;