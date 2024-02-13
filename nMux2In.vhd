library ieee;
use ieee.std_logic_1164.all;

ENTITY nMux2In IS

  generic(
    n: integer := 4
  );

  PORT(
	    i_op0 : in std_logic_vector(n-1 downto 0);
	    i_op1 : in std_logic_vector(n-1 downto 0);
	    i_choice : in std_logic;
	    o_out : out std_logic_vector(n-1 downto 0)
	  );
	  
END ENTITY nMux2In;

architecture rtl of nMux2In is
  
  signal int_out: STD_LOGIC_VECTOR (n-1 downto 0);

	COMPONENT mux1bit 

  PORT(
	    i_op0 : in std_logic;
	    i_op1 : in std_logic;
	    i_choice : in std_logic;
	    o_out : out std_logic
	  );
	  
	END COMPONENT;
	
	begin 
	  
  nBitSel: for k in 0 to n-1 generate
      S_k: mux1bit 
      PORT MAP(
            i_op0 => i_op0(k),
            i_op1 => i_op1(k),
            i_choice => i_choice,
            o_out => int_out(k)
      );
end generate nBitSel;

o_out <= int_out;

end architecture;