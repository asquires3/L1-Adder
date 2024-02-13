library ieee;
use ieee.std_logic_1164.ALL;

entity shiftNbit is
        
        generic(
          -- size of register, must be >= 2
          n: integer := 4;
          -- use shift = -1 for lshift, 1 for rshift, must be one of these 2
          shift: integer := 1
        );
        port(i_clock, i_load, i_shift, i_resetBar : in std_logic;
              i_value : in std_logic_vector(n-1 downto 0);
              o_value : out std_logic_vector(n-1 downto 0));
              
end shiftNbit;

--reset has precedence over load
--load has precedence over shift

architecture rtl of shiftNbit is
        signal int_valueIn, int_valueOut : std_logic_vector(n-1 downto 0);
        
        component enARdff_2
                port(
                        i_resetBar : in std_logic;
                        i_d : in std_logic;
                        i_enable : in std_logic;
                        i_clock : in std_logic;
                        o_q, o_qBar : out std_logic);
        end component;
        
begin

process(i_shift, i_load, i_value, int_valueOut, i_clock) is
  
  begin -- just instantiating the first and last registers since these are the only ones that may be different
  if shift < 0 then --lshift
    int_valueIn(0) <= (i_shift AND int_valueOut(n-1) and not i_load) or (i_load and i_value(0)) or (not i_shift and int_valueOut(0) and not i_load);
    int_valueIn(n-1) <= (i_shift AND int_valueOut(n-2) and not i_load) or (i_load and i_value(n-1)) or (not i_shift and int_valueOut(n-1) and not i_load);
  
  else --rshift
    int_valueIn(0) <= (i_shift AND int_valueOut(1) and not i_load) or (i_load and i_value(0)) or (not i_shift and int_valueOut(0) and not i_load);
    int_valueIn(n-1) <= (i_shift AND int_valueOut(0) and not i_load) or (i_load and i_value(n-1)) or (not i_shift and int_valueOut(n-1) and not i_load);
  
  end if;
  
  if n>2 then --2 bit registers have the above rules, more than 2 also get these
    for k in 1 to n-2 loop
      int_valueIn(k) <= (i_shift AND int_valueOut(k+shift) and not i_load) or (i_load and i_value(k)) or (not i_shift and int_valueOut(k) and not i_load);
    end loop;
  end if;
  
end process;


nFF: for k in 0 to n-1 generate
    enARdff2_k: enARdff_2 
    PORT MAP(
      i_resetBar => i_resetBar,
      i_d => int_valueIn(k),
      i_enable => '1',
      i_clock => i_clock,
      o_q => int_valueOut(k)
      );
end generate nFF;
                
o_value <= int_valueOut;

end architecture rtl;   
   

