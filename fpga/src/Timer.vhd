library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.numeric_std.all;

entity Timer is 
	generic(Ticks : integer := 10);
	Port (
	RST: in Std_logic;
	CLK: in Std_logic;
	SYN:  out Std_logic );  
end Timer;

architecture Behavioral of Timer is
signal Cn, Cp : integer := 0;  
begin
	Combinational : process(Cp)
	begin
		if Cp = (Ticks-1) then -- por ser una variable de tipo entera
			Cn <= 0;
			SYN <= '1';
		else
			Cn <= Cp + 1;
			SYN <= '0';	
		end if;
	end process Combinational;
	
	Sequential : process(RST, CLK)
	begin
		if RST = '0' then
			Cp <= 0;
		elsif CLK'event and CLK = '1' then
			Cp <= Cn;
		end if;
	end process Sequential;	
end Behavioral;