--used to count the number of shifts from the exponent difference

library ieee;
use ieee.std_logic_1164.all;

ENTITY countComp IS

  PORT(
      i_GClock, i_GReset, i_countReset, i_enableCount : in std_logic;
      i_compare : in std_logic_vector(7 downto 0);
      o_equal : out std_logic;
      o_countOut : out std_logic_vector(7 downto 0)
	  );
	  
END ENTITY countComp;

architecture rtl of countComp is

  signal int_ALUout, int_regIn, int_regOut : std_logic_vector(7 downto 0);
  
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
	
	  	component shiftNbit
	  generic(n: integer);
	  port(i_clock, i_load, i_shift, i_resetBar : in std_logic;
              i_value : in std_logic_vector(n-1 downto 0);
              o_value : out std_logic_vector(n-1 downto 0));
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
	  
	  	component shiftNBitArithm is
        generic(
          n: integer;
          shift: integer
        );
        port(i_clock, i_load, i_shift, i_resetBar, i_shiftIn : in std_logic;
              i_value : in std_logic_vector(n-1 downto 0);
              o_value : out std_logic_vector(n-1 downto 0));
              
  end component;
	  
	 begin
	   
	   topMux: nMux2In
	       generic map(n=>8)
	       port map(
	         i_op0 => "00000000",
	         i_op1 => int_ALUout,
	         i_choice => i_enableCount,
	         o_out => int_regIn
	       );
	       
	       
	       --currently always counting down when enable is high, could change to enable/disable countign action
	    countReg: shiftNBitArithm 
	     generic map(n=>8, shift=>1)
	     port map(
	       i_clock => i_GCLock,
	       i_resetBar => i_GReset,
	       i_load => '1',--change?
	       i_shift => '0',
	       i_shiftIn => '0',
	       i_value => int_regIn,
	       o_value => int_regOut
	     );
	     
	     incrALU: nFullAdderSubtractor
	       generic map(n=>8)
	       port map(
	         i_subControl => '0',
	         i_a => int_regOut,
	         i_b => "00000001",
	         o_sumOut => int_ALUout
	       );
	       
	       o_countOut <= int_regOut;
	       o_equal <= (int_regOut(7) xnor i_compare(7)) and
(int_regOut(6) xnor i_compare(6)) and
(int_regOut(5) xnor i_compare(5)) and
(int_regOut(4) xnor i_compare(4)) and
(int_regOut(3) xnor i_compare(3)) and
(int_regOut(2) xnor i_compare(2)) and
(int_regOut(1) xnor i_compare(1)) and
(int_regOut(0) xnor i_compare(0));
	       
	       end architecture;
	       
	       