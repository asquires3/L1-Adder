LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity debouncer is
	port(i_clock, i_in, i_resetBar : in STD_LOGIC;
			o_value : out STD_LOGIC);
			
end entity debouncer;


--must be button down for 2 cycles before becoming 1. Only takes 1 cycle to drop back to 0.
architecture rtl of debouncer is
  
	signal int_dIN1, int_dIN2, int_dOUT1, int_dOUT2 : STD_LOGIC;
	
	COMPONENT enardFF_2
	PORT(
		i_d			: IN	STD_LOGIC;
		i_clock			: IN	STD_LOGIC;
		i_resetBar : IN STD_LOGIC;
		i_enable : IN STD_LOGIC;
		o_q, o_qBar		: OUT	STD_LOGIC
		);
	END COMPONENT;
		
begin
  priDFF: enardFF_2
    PORT MAP(
      i_clock => i_clock,
      i_resetBar => i_resetBar,
      i_enable => '1',
      i_d => int_dIN1,
      o_q => int_dOUT1
  );
  secDFF: enardFF_2
    PORT MAP(
      i_clock => i_clock,
      i_resetBar => i_resetBar,
      i_enable => '1',
      i_d => int_dIN2,
      o_q => int_dOUT2
    );
    
    int_dIN1 <= NOT (i_in NAND (int_dOUT2 OR (int_dOUT2 NOR (NOT int_dOUT1))));
    int_dIN2 <= i_in AND NOT int_dOUT2 AND NOT int_dOUT1;
    o_value <= NOT int_dOUT1 NOR int_dOUT2;
    
end architecture rtl;
