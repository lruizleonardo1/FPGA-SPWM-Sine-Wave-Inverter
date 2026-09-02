library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;  -- para comparación SIN > CNT (como en tus otros módulos)

entity SPWM is
    generic(
        TS     : integer := 6510; -- Ticks para la FRECUENCIA DE LA SENOIDE (BITS=7 -> ~60 Hz)
        BITS   : integer := 7;    -- 128 puntos de la LUT
        TS_PWM : integer := 2     -- NUEVO: prescaler para la PORTADORA (1 = original; 2,4,... = pulsos más anchos)
    );
    port(
        RST  : in std_logic;
        CLK  : in std_logic;
        ENI  : in std_logic;
        REN  : out std_logic;
        LEN  : out std_logic;
        PWMA : out std_logic;
        PWMB : out std_logic
    );
end SPWM;

architecture Structural of SPWM is

    -- Componentes -------------------------------------------------------------
    component Timer is
        generic(Ticks : integer := 10);
        Port (
            RST : in Std_logic;
            CLK : in Std_logic;
            SYN : out Std_logic
        );
    end component;

    component Counter is
        generic(BusWidth : integer  := 2);
        port(
            RST : in std_logic;
            CLK : in std_logic;
            ENA : in std_logic;
            CNT : out std_logic_vector(BusWidth - 1 downto 0)
        );
    end component;

    component SineLut is
        Port (
            ANG : in  STD_LOGIC_VECTOR(6 downto 0);
            SIN : out STD_LOGIC_VECTOR(12 downto 0)
        );
    end component;

    component CounterX is
        port (
            RST  : in std_logic;
            CLK  : in std_logic;
            INC  : in std_logic;
            COUT : out std_logic_vector (12 downto 0)
        );
    end component;
    ---------------------------------------------------------------------------

    -- Señales internas -------------------------------------------------------
    signal SYN_sine : std_logic;  -- pulso para avanzar ANG (senoide)
    signal SYN_pwm  : std_logic;  -- pulso para avanzar CNT (portadora)
    signal PWM      : std_logic;

    signal ANG      : std_logic_vector(6 downto 0);
    signal SIN      : std_logic_vector(12 downto 0);
    signal CNT      : std_logic_vector(12 downto 0);

begin

    -- Comparador SPWM
    PWM <= '1' when SIN > CNT else '0';

    -- Cambio de signo según el MSB de ANG (bit 6)
    PWMA <= PWM when ANG(6) = '0' else '0';
    PWMB <= PWM when ANG(6) = '1' else '0';

    REN <= ENI;
    LEN <= ENI;

    --=========================
    -- Generación de la SENOIDE
    --=========================
    -- Timer para la senoide (60 Hz aprox. con TS=6510 y BITS=7)
    U01 : Timer
        generic map(TS)
        port map(RST => RST, CLK => CLK, SYN => SYN_sine);

    -- Contador de ángulo 0..127
    U02 : Counter
        generic map(BITS)
        port map(RST => RST, CLK => CLK, ENA => SYN_sine, CNT => ANG);

    -- LUT seno 128 puntos
    U03 : SineLut
        port map(ANG => ANG, SIN => SIN);

    --==============================
    -- Generación de la PORTADORA
    --==============================
    -- Timer para la portadora: divide el reloj
    -- TS_PWM = 1 -> comportamiento original (~15 kHz)
    -- TS_PWM = 4 -> f_sw ~ 1/4 y pulsos 4× más anchos, etc.
    U05 : Timer
        generic map(TS_PWM)
        port map(RST => RST, CLK => CLK, SYN => SYN_pwm);

    -- Rampa CNT (0..3254) avanza sólo cuando SYN_pwm da un pulso
    U04 : CounterX
        port map(RST => RST, CLK => CLK, INC => SYN_pwm, COUT => CNT);

end Structural;


--Library IEEE;
--use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;
--
--Entity SPWM is	  
--	generic(		
--	TS : integer := 6510;
--	BITS : integer := 7 
--	);
--	port(
--	RST : in std_logic;
--	CLK : in std_logic;
--	ENI : in std_logic;
--	REN : out std_logic;
--	LEN : out std_logic;					
--	PWMA : out std_logic;
--	PWMB : out std_logic
--	);
--end SPWM;
--
--Architecture Structural of SPWM is	 
------Components--------------------------------------------------------------------------
--	component Timer is 
--		generic(Ticks : integer := 10);
--		Port (
--			RST: in Std_logic;
--			CLK: in Std_logic;
--			SYN:  out Std_logic );  
--		end component Timer;	
--	------------------------------------------------------------------------------------
--	component Counter is
--		generic(BusWidth : integer  := 2);
--		port(
--			RST : in std_logic;
--			CLK : in std_logic;
--			ENA : in std_logic;
--			CNT : out std_logic_vector(BusWidth - 1 downto 0)
--			);  
--		end component Counter;
--	------------------------------------------------------------------------------------
--	component SineLut is
--	    Port ( 
--			ANG : in STD_LOGIC_VECTOR(6 downto 0);
--		    SIN : out STD_LOGIC_VECTOR(12 downto 0)
--		);
--		end component SineLut; 
--	------------------------------------------------------------------------------------
--	component CounterX is
--		port (
--		RST : in std_logic;
--		CLK : in std_logic;
--		INC : in std_logic;
--		COUT : out std_logic_vector (12 downto 0)
--		);
--		end component CounterX;
--	
----signals-------------------------------------------------------------------------------
--signal SYN, PWM : std_logic;
--signal ANG : std_logic_vector(6 downto 0);
--signal SIN : std_logic_vector(12 downto 0);
--signal CNT : std_logic_vector(12 downto 0);
--
--	begin 	
--	PWMA <= PWM when ANG(6) = '0' else '0';
--	PWMB <= PWM when ANG(6) = '1' else '0';
--	PWM  <= '1' when SIN > CNT else '0';
--	
--	REN <= ENI;
--	LEN <= ENI;
--		
--	U01 : Timer generic map(TS) port map(RST, CLK, SYN);			 	
--	U02 : Counter generic map(BITS) port map(RST, CLK, SYN, ANG);
--	U03 : SineLut port map(ANG, SIN);	
--	U04 : CounterX port map(RST, CLK, '1', CNT);
--	
--end Structural;