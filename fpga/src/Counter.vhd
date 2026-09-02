Library IEEE; 		
use IEEE.std_logic_1164.all; 
Use IEEE.NUMERIC_STD.ALL;
  
entity Counter is
	generic(BusWidth : integer  := 2);
	port(
	RST : in std_logic;
	CLK : in std_logic;
	ENA : in std_logic;
	CNT : out std_logic_vector(BusWidth - 1 downto 0)
	);  
end Counter;

architecture Behavioral of Counter is	 
signal Cp, Cn : integer := 0;	  

begin 
	
  Combinational : process(ENA, CLK)
  begin 		 
	  if ENA = '1' then
		  Cn <= Cp + 1 ;
	  else
		  Cn <= Cp;
	  end if; 
	  
	  CNT <= std_logic_vector(to_unsigned(Cp, BusWidth));
	  
  end process Combinational;
  
  Sequential : process(CLK, RST)
  begin 	   
	  if RST = '0' then
		  Cp <= 0;
	  elsif CLK 'event and CLK = '1' then
		  Cp <= Cn;	
	  end if;
	 		  
  end process Sequential;
  
end Behavioral; 