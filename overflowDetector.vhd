LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY overflowDetector IS
	PORT(
		i_CarryIn, i_SumIn		: IN	STD_LOGIC;
		i_Ai, i_Bi		: IN	STD_LOGIC;
		o_Overflow	: OUT	STD_LOGIC);
END overflowDetector;

ARCHITECTURE rtl OF overflowDetector IS
	SIGNAL int_Overflow: STD_LOGIC;

BEGIN

	-- Concurrent Signal Assignment
	int_Overflow <= (i_Ai XNOR i_Bi) and (i_Ai xor i_SumIn); 
	-- Overflow occurs if the sign bit of A and B is the same,
	-- but the output of the sum is different.

	-- Output Driver
	o_Overflow <= int_Overflow;

END rtl;
