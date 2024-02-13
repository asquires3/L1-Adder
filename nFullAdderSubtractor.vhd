
library ieee;
use ieee.std_logic_1164.all;

ENTITY nFullAdderSubtractor IS

  generic(
    n: integer := 4
  );

  PORT(
	    i_subControl : in std_logic; -- 1 for subtraction
	    i_a : in std_logic_vector(n-1 downto 0);
	    i_b : in std_logic_vector(n-1 downto 0);
	    o_carryOut : out std_logic;
	    o_sumOut : out std_logic_vector(n-1 downto 0);
	    o_overflow : out std_logic
	  );
	  
END ENTITY nFullAdderSubtractor;

architecture rtl of nFullAdderSubtractor is

  signal int_carryOut : std_logic;
  signal int_Sum, int_b : STD_LOGIC_VECTOR (n-1 downto 0);
  signal xorAgainst: std_logic_vector (n-1 downto 0);
  
	COMPONENT nBitAdder
	  generic(n: integer);
	PORT(
		i_carryIn: in std_logic;
		i_a,i_b: in std_logic_vector;
		o_carryOut: out std_logic;
		o_SumOut: out std_logic_vector
		);
	END COMPONENT;
	
	component nBitXor
	  generic(n: integer);
	  port(
	   i_a,i_b : in std_logic_vector;
	   o_out : out std_logic_vector
	  );
	 end component;
	 
	 begin
	   
	   checkSub: process(i_subControl) -- expands sub control to an n length vector
	     begin
	       xorAgainst <= (others => i_subControl);
	     end process;
	     
	   xorrer: nBitXor
	     generic map(n => n)
	     port map(
	       i_a => xorAgainst,
	       i_b => i_b,
	       o_out => int_b
	     );
	     
	   adder: nBitAdder
	     generic map(n => n)
	     port map(
	       i_carryIn => i_subControl,
	       i_a => i_a,
	       i_b => int_b,
	       o_carryOut => int_carryOut,
	       o_SumOut => int_Sum
	     );
	     
	     o_carryOut <= int_carryOut;
	     o_sumOut <= int_Sum;
	     o_overflow <= int_Sum(n-1) and (i_a(n-1) xnor int_b(n-1));
	    end rtl;
	   