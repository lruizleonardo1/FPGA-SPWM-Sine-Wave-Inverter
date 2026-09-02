Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

Entity CounterX is
	port (
	RST : in std_logic;
	CLK : in std_logic;
	INC : in std_logic;
	COUT : out std_logic_vector (12 downto 0)
	);
end CounterX;

Architecture Behavioral of CounterX is
signal Qp, Qn : std_logic_vector (12 downto 0) := (others => '0');
begin
Combinational : process (Qp, INC)
begin
    if INC = '1' then
        if Qp = "0110010110110" then  --0110010110110 3254 en decimal	
            Qn <= (others => '0');    
        else
            Qn <= Qp + 1;           
        end if;
    else
        Qn <= Qp;                    
    end if;
end process Combinational;	 
	
Sequential : process (RST, CLK)
begin
    if RST = '0' then
        Qp <= (others => '0');        
    elsif rising_edge(CLK) then
        Qp <= Qn;                     
    end if;
end process Sequential;

COUT <= Qp;  
end Behavioral;