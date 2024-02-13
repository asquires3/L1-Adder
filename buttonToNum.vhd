LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity buttonToNum is
	port(i_GClock, i_in0, i_in1, i_GReset : in STD_LOGIC;
			o_Aout, o_Bout : out std_logic_vector(15 downto 0);
			o_finished : out std_logic
			);
			
end entity buttonToNum;

architecture rtl of buttonToNum is
  
  signal int_counterDone, int_loadVal, int_buttonUp, int_enableCount, int_resetCount, int_regAdone : std_logic;
  signal int_loadA, int_loadB, int_shiftA, int_shiftB : std_logic;
  
  signal int_deb0, int_deb1 : std_logic;
  
  signal int_counterIn, int_counterOut, int_ALUout : std_logic_vector(4 downto 0);
  
  signal int_curState, int_nextState : std_logic_vector(8 downto 0);
  
  signal int_nextBit,  int_Aout, int_Bout, int_valIn, int_curRegOut : std_logic_vector(15 downto 0);
  
  COMPONENT debouncer
	port(i_clock, 
	     i_in, 
	     i_resetBar : in STD_LOGIC;
			 o_value : out STD_LOGIC);
  end component;
  
  component debouncer_2 IS
	PORT(
		i_resetBar		: IN	STD_LOGIC;
		i_clock			: IN	STD_LOGIC;
		i_raw			: IN	STD_LOGIC;
		o_clean			: OUT	STD_LOGIC);
		end component;
  
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
    
	 component nFullAdderSubtractor
	 generic(n: integer);
  PORT(
	    i_subControl : in std_logic; -- 1 for subtraction
	    i_a : in std_logic_vector(n-1 downto 0);
	    i_b : in std_logic_vector(n-1 downto 0);
	    o_carryOut : out std_logic;
	    o_sumOut : out std_logic_vector(n-1 downto 0);
	    o_overflow : out std_logic
	  );
	  end component;
  
  component shiftNBitArithm is
        generic(
          n: integer;
          shift: integer
        );
        port(i_clock, i_load, i_shift, i_resetBar, i_shiftIn : in std_logic;
              i_value : in std_logic_vector(n-1 downto 0);
              o_value : out std_logic_vector(n-1 downto 0));
              
  end component;
  
  component nBitOrrer is
    generic(n: integer);
    port(
      i_a, i_b : in std_logic_vector(n-1 downto 0);
      o_out :out std_logic_vector(n-1 downto 0)
    );
  end component;
  
  component nMux2In
	  generic(n: integer);
  PORT(
	    i_op0 : in std_logic_vector(n-1 downto 0);
	    i_op1 : in std_logic_vector(n-1 downto 0);
	    i_choice : in std_logic;
	    o_out : out std_logic_vector(n-1 downto 0)
	  );
	  end component;

begin
    
  int_nextState(0) <= (int_curState(0) and not int_buttonUp) or (int_curState(2) and not int_counterDone);
  int_nextState(1) <= int_curState(0) and (int_buttonUp);
  int_nextState(2) <= int_curState(1);
  
  int_nextState(3) <= int_curState(2) and int_counterDone;
  
  int_nextState(4) <= int_curState(3) or (int_curState(6) and not int_counterDone) or (int_curState(4) and not int_buttonUp);
  int_nextState(5) <= int_curState(4) and int_buttonUp;
  int_nextState(6) <= int_curState(5);
  int_nextState(7) <= int_curState(6) and int_counterDone;
  
  int_nextState(8) <= int_curState(7) or int_curState(8);
  
  int_buttonUp <= (not i_in0 and int_deb0) or (not i_in1 and int_deb1);
  
  int_nextBit <= int_loadVal&"000000000000000";
  int_loadVal <= int_deb1;
  
  int_regAdone <= int_curState(4) or int_curState(5) or int_curState(6) or int_curState(7);
  
  s_0: enARdFF_2_high
			port map(
				i_resetBar => i_GReset,
				i_d => int_nextState(0),
				i_enable => '1',
				i_clock => i_GClock,
				o_q => int_curState(0)
			);
			
  	states: for i in 1 to 8 generate
		s_i: enARdFF_2
			port map(
				i_resetBar => i_GReset,
				i_d => int_nextState(i),
				i_enable => '1',
				i_clock => i_GClock,
				o_q => int_curState(i)
			);
		end generate states;  
    
  curReg: nMux2In
    generic map(n => 16)
    port map(
      i_op0 => int_Aout,
      i_op1 => int_Bout,
      i_choice => int_regAdone,
      o_out => int_curRegOut
    );
	     
	     incrALU: nFullAdderSubtractor
	       generic map(n=>5)
	       port map(
	         i_subControl => '0',
	         i_a => int_counterOut,
	         i_b => "00001",
	         o_sumOut => int_ALUout
	       );
    
    muxAbove: nMux2In
      generic map(n=>5)
      port map(
        i_op0 => int_ALUout,
        i_op1 => "00000",
        i_choice => int_resetCount,
        o_out => int_counterIn
      );
    
  count: shiftNBitArithm
    generic map(n=>5, shift=>1)
    port map(
	           i_clock => i_GClock,
	           i_resetBar => i_GReset,
	           i_load => int_enableCount,
	           i_shift => '0',
	           i_shiftIn => '0',
	           i_value => int_counterIn,
	           o_value => int_counterOut      
    );
  
  valIn: nBitOrrer
    generic map(n => 16)
    port map(
      i_a => int_nextBit,
      i_b => int_curRegOut,
      o_out => int_valIn
    );
		
		deb0: debouncer_2 
	 	     PORT MAP(
		      i_resetBar => i_GReset,
		      i_clock	=> i_GClock,
	       	i_raw => i_in0,
		      o_clean => int_deb0);
			 
			 deb1: debouncer_2 
	 	     PORT MAP(
		      i_resetBar => i_GReset,
		      i_clock	=> i_GClock,
	       	i_raw => i_in1,
		      o_clean => int_deb1);
  
		regA: shiftNBitArithm
	         generic map(n=>16, shift=>1)
	         port map(
	           i_clock => i_GClock,
	           i_resetBar => i_GReset,
	           i_load => int_loadA,
	           i_shift => int_shiftA,
	           i_shiftIn => '0',
	           i_value => int_valIn,
	           o_value => int_Aout
	         );
	         
	     regB: shiftNBitArithm
	         generic map(n=>16, shift=>1)
	         port map(
	           i_clock => i_GClock,
	           i_resetBar => i_GReset,
	           i_load => int_loadB,
	           i_shift => int_shiftB,
	           i_shiftIn => '0',
	           i_value => int_valIn,
	           o_value => int_Bout
	         );
	    
  int_counterDone <= int_counterIn(4);
  
  int_loadA <= int_curState(0) and (int_buttonUp);
  int_loadB <= int_curState(4) and (int_buttonUp);
  
  int_shiftA <= int_curState(2) and not int_counterDone;
  int_shiftB <= int_curState(6) and not int_counterDone;
  
  int_enableCount <= int_curState(2) or int_curState(3) or int_curState(6) or int_curState(7);
  int_resetCount <= int_curState(3);
		
	o_Aout <= int_Aout;
	o_Bout <= int_Bout;	
	
	o_finished <= int_curState(8);
	
end architecture rtl;

