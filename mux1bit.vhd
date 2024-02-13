library ieee;
use ieee.std_logic_1164.all;

ENTITY mux1bit IS

  PORT(
	    i_op0 : in std_logic;
	    i_op1 : in std_logic;
	    i_choice : in std_logic;
	    o_out : out std_logic
	  );
	  
END ENTITY mux1bit;

architecture rtl of mux1bit is
  begin
    o_out <= (i_op0 and not i_choice) or (i_op1 and i_choice);
  end architecture;
