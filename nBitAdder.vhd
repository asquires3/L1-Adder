library ieee;
use ieee.std_logic_1164.all;

ENTITY nBitAdder IS

  generic(
    n: integer := 4
  );

  PORT(
	    i_carryIn : in std_logic;
	    i_a : in std_logic_vector(n-1 downto 0);
	    i_b : in std_logic_vector(n-1 downto 0);
	    o_carryOut : out std_logic;
	    o_SumOut : out std_logic_vector(n-1 downto 0)
	  );
	  
END ENTITY nBitAdder;

architecture rtl of nBitAdder is

  signal int_Sum, int_CarryOut : STD_LOGIC_VECTOR (n-1 downto 0);

	COMPONENT oneBitAdder
	PORT(
		i_CarryIn		: IN	STD_LOGIC;
		i_Ai, i_Bi		: IN	STD_LOGIC;
		o_Sum, o_CarryOut	: OUT	STD_LOGIC);
	END COMPONENT;
	
begin

lsb: oneBitAdder
      PORT MAP(
            i_CarryIn => i_carryIn,
            i_Ai => i_a(0),
            i_Bi => i_b(0),
            o_sum => int_Sum(0),
            o_CarryOut => int_CarryOut(0));

nAdders: for k in 1 to n-1 generate
      FA_k: oneBitAdder 
      PORT MAP(
            i_Ai => i_a(k),
            i_Bi => i_b(k),
            i_CarryIn => int_CarryOut(k-1),
            o_sum => int_Sum(k) ,
            o_CarryOut => int_CarryOut(k) 
      );
end generate nAdders;

o_SumOut <= int_Sum;
o_carryOut <= int_CarryOut(n-1);

end rtl;