
library ieee;
use ieee.std_logic_1164.all;

entity bcd4bit is 
  port(
    i_bcd : in std_logic_vector(3 downto 0);
			o_bcd10, o_bcd11, o_bcd12, o_bcd13, o_bcd14, o_bcd15, o_bcd16 : out std_logic;
			o_bcd0, o_bcd1, o_bcd2, o_bcd3, o_bcd4, o_bcd5, o_bcd6 : out std_logic
  );
end entity;

architecture basic of bcd4bit is

  signal int_adderOut, int_bcd1digit, int_bcd2digit : std_logic_vector(3 downto 0);
  signal int_bcd10, int_bcd11, int_bcd12, int_bcd13, int_bcd14, int_bcd15, int_bcd16 : std_logic;
  signal int_bcd0, int_bcd1, int_bcd2, int_bcd3, int_bcd4, int_bcd5, int_bcd6 : std_logic;
  signal int_greq : std_logic;

  component comparator4bit
  port(
    i_a,i_b : in std_logic_vector;
    o_aGreaterEQ : out std_logic
  );
  end component;
  
  component selNBit
		generic(n: integer);
		port(
			i_sel: in std_logic;
			i_a, i_b: in std_logic_vector;
			o_c : out std_logic_vector
		);
	end component;
	
	component bcdDriver
		port(
			i_digit : in std_logic_vector(3 downto 0);
			o_bcd0, o_bcd1, o_bcd2, o_bcd3, o_bcd4, o_bcd5, o_bcd6 :out std_logic
		);
	end component;
	
	component nFullAdderSubtractor
		generic(n: integer);
		port(
			i_subControl : in std_logic; --1 for subtraction
			i_a : in std_logic_vector;
			i_b : in std_logic_vector;
			o_carryOut : out std_logic;
			o_sumOut : out std_logic_vector;
			o_overflow : out std_logic
		);
	end component;
	
	begin
	  
	  bcd1sel: selNBit
	   generic map(n => 4)
	   port map(
	     i_a => "0001",
	     i_b => "0000",
	     i_sel => int_greq,
	     o_c => int_bcd1digit
	   );
	  
	  bcd2sel: selNBit
	   generic map(n => 4)
	   port map(
	     i_a => int_adderOut,
	     i_b => i_bcd,
	     i_sel => int_greq,
	     o_c => int_bcd2digit
	   );
	     
	  subtract: nFullAdderSubtractor
	    generic map(n => 4)
	    port map(
	     i_subControl => '1',
	     i_a => i_bcd,
	     i_b => "1010",
	     o_sumOut => int_adderOut
	    );
	   
	   compare: comparator4bit
	     port map(
	       i_a => i_bcd,
	       i_b => "1010",
	       o_aGreaterEQ => int_greq
	     );
		  
		 bcd1: bcdDriver
			port map(
				i_digit =>int_bcd1digit,
				o_bcd0 => int_bcd10, 
				o_bcd1 => int_bcd11, 
				o_bcd2 => int_bcd12, 
				o_bcd3 => int_bcd13, 
				o_bcd4 => int_bcd14, 
				o_bcd5 => int_bcd15, 
				o_bcd6 => int_bcd16
			);
			
		
		 bcd2: bcdDriver
			port map(
				i_digit =>int_bcd2digit,
				o_bcd0 => int_bcd0, 
				o_bcd1 => int_bcd1, 
				o_bcd2 => int_bcd2, 
				o_bcd3 => int_bcd3, 
				o_bcd4 => int_bcd4, 
				o_bcd5 => int_bcd5, 
				o_bcd6 => int_bcd6
			);
	     
				o_bcd0 <= int_bcd0;
				o_bcd1 <= int_bcd1; 
				o_bcd2 <= int_bcd2; 
				o_bcd3 <= int_bcd3; 
				o_bcd4 <= int_bcd4; 
				o_bcd5 <= int_bcd5; 
				o_bcd6 <= int_bcd6;
				
				o_bcd10 <= int_bcd10; 
				o_bcd11 <= int_bcd11; 
				o_bcd12 <= int_bcd12; 
				o_bcd13 <= int_bcd13; 
				o_bcd14 <= int_bcd14; 
				o_bcd15 <= int_bcd15; 
				o_bcd16 <= int_bcd16;
				
end architecture;
	       
	       