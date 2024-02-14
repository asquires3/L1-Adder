library ieee;
use ieee.std_logic_1164.all;

entity control is
    port(
      i_clock, i_resetBar : in std_logic;
      i_expDiff : in std_logic_vector (6 downto 0);
      i_bigALUResult : in std_logic_vector(9 downto 0);
      i_LRReg : in std_logic_vector(9 downto 0);
      i_sameSign : in std_logic;
      
      o_loadA, o_loadB, o_loadExpDiff,
        o_loadIncDecReg, o_incOrDecr, o_incDecAction, 
        o_shiftIn, o_loadRShiftReg, o_shiftRShiftReg, 
        o_shiftDir, o_loadLRReg, o_shiftLRReg, o_loadFinal : out std_logic;
      --o_resetCounter, o_enableCounter : out std_logic;
      o_curState : out std_logic_vector(6 downto 0)
    );
end entity;

architecture rtl of control is
  
  signal int_counterDone, int_expDifferenceIsZero : std_logic;
  signal int_curState, int_nextState : std_logic_vector(6 downto 0);
  signal int_specialCounterVal, int_counterOut : std_logic_vector(7 downto 0);
  
	component enARdff_2
       port(
          i_resetBar : in std_logic;
          i_d : in std_logic;
          i_enable : in std_logic;
          i_clock : in std_logic;
          o_q, o_qBar : out std_logic);
    end component;
    
	component enARdFF_2_high
       port(
          i_resetBar : in std_logic;
          i_d : in std_logic;
          i_enable : in std_logic;
          i_clock : in std_logic;
          o_q, o_qBar : out std_logic);
    end component;
    
	  component countComp
	    PORT(
      i_GClock, i_GReset, i_countReset, i_enableCount : in std_logic;
      i_compare : in std_logic_vector(7 downto 0);
      o_equal : out std_logic;
      o_countOut : out std_logic_vector(7 downto 0)
    );
  end component;
  
begin
    
    int_expDifferenceIsZero <=  not (i_expDiff(6) or
i_expDiff(5) or
i_expDiff(4) or
i_expDiff(3) or
i_expDiff(2) or
i_expDiff(1) or
i_expDiff(0));
    
    --starting state, reset all registers
    int_nextState(0) <= '0';
    --load registers a/b
    int_nextState(1) <= int_curState(0);
    --load the exponent difference register
    int_nextState(2) <= (int_curState(1) and not int_expDifferenceIsZero) or (int_curState(2) and not int_counterDone);
    int_nextState(3) <= (int_curState(2) and int_counterDone) or (int_curState(1) and int_expDifferenceIsZero);
    
    --overflow in the bigALU, always a shift
    int_nextState(4) <= int_curState(3) and i_bigALUResult(9);
    
    --no overflow in the bigALU, or state 4
    int_nextState(5) <= (int_curState(3) and not i_bigALUResult(9)) or 
                          (int_curState(4)) or (int_curState(5) and not i_LRReg(8));
    int_nextState(6) <= (int_curState(5) and  i_LRReg(8)) or int_curState(6); 
    
    	s_0: enARdFF_2_high
			port map(
				i_resetBar => i_resetBar,
				i_d => int_nextState(0),
				i_enable => '1',
				i_clock => i_clock,
				o_q => int_curState(0)
			);
			
  	states: for i in 1 to 6 generate
		s_i: enARdFF_2
			port map(
				i_resetBar => i_resetBar,
				i_d => int_nextState(i),
				i_enable => '1',
				i_clock => i_clock,
				o_q => int_curState(i)
			);
		end generate states;  
		
		int_specialCounterVal <= '0'&i_expDiff;
		counter : countComp
		  port map(
		    i_GClock => i_clock,
		    i_GReset => i_resetBar,
		    i_countReset => int_curState(3),
		    i_enableCount => int_curState(2),
		    i_compare => int_specialCounterVal,
		    o_equal => int_CounterDone,
		    o_countOut => int_counterOut
		  );
    
    o_loadA <= int_curState(0);
    o_loadB <= int_curState(0);
    
    o_loadExpDiff <= int_curState(1);
    o_shiftIn <= int_curState(1);
    o_loadRShiftReg <= int_curState(1);
    
    o_shiftRShiftReg <= int_curState(2) and not int_counterDone;
    
    o_loadLRReg <= int_curState(3);
    
    --might need ot change the state the things happen in
    o_incDecAction <= (int_curState(4)) or (int_curState(5));
    --0 for inc 1 for dec
    o_loadIncDecReg <= int_curState(3) or int_curState(4) or (int_curState(5) and not i_LRReg(8));
    --if the signs are the same, then the magnitude can only increase, and
    --we will be shifting left
    o_shiftDir <= i_sameSign;
    --same thing for the exponent, if the sign is same always incr
    o_incOrDecr <= not i_sameSign;
    --using 0 for inc, since it is on a adder, and 1 for decr for sub control
    --shift left = 1, shift r = 0
    o_shiftLRReg <= int_curState(4) or (int_curState(5) and not I_LRReg(8));
    o_loadFinal <= int_curState(6);
    
    o_curState <= int_curState;
		
end architecture;