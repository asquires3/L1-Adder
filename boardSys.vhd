library ieee;
use ieee.std_logic_1164.all;

entity boardSys is
	port(i_GClock, i_in0, i_in1, i_GReset : in STD_LOGIC;
			i_ABSwitch, i_SSwitch : in STD_LOGIC;
			o_ledsOut : out std_logic_vector(15 downto 0);
			o_overflow, o_oneDown, o_zeroDown, o_inputDone : out std_logic
			);
			end;
			
architecture rtl of boardSys is
    
    signal int_signA, int_signB, int_fullSysClock, int_overflow, int_finished: std_logic;
	 signal int_in1, int_in0 : std_logic;
	 signal int_ABorS, int_AorB : std_logic_vector(15 downto 0);
    signal int_mantissaA, int_mantissaB : std_logic_vector (7 downto 0);
    signal int_exponentA, int_exponentB :  std_logic_vector (6 downto 0);
    
    signal int_Aout, int_Bout, int_sum : std_logic_vector(15 downto 0);
    
    component buttonToNum 
	   port(i_GClock, i_in0, i_in1, i_GReset : in STD_LOGIC;
			o_Aout, o_Bout : out std_logic_vector(15 downto 0);
			o_finished : out std_logic
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
	  
			component fullSys
			PORT(
      i_signA, i_signB, i_GClock, i_GReset : in std_logic;
      i_mantissaA, i_mantissaB : in std_logic_vector (7 downto 0);
      i_exponentA, i_exponentB : in std_logic_vector (6 downto 0);
      o_overflow : out std_logic;
      o_sum : out std_logic_vector(15 downto 0)
	   );
	   end component;
	   
	   begin
	       int_signA <= int_Aout(15);
	       int_exponentA <= int_Aout(14 downto 8);
	       int_mantissaA <= int_Aout(7 downto 0);
	       	       
	       int_signB <= int_Bout(15);
	       int_exponentB <= int_Bout(14 downto 8);
	       int_mantissaB <= int_Bout(7 downto 0);
	       
	       int_fullSysClock <= i_GClock and int_finished;
	       
			 int_in1 <= not i_in1;
			 int_in0 <= not i_in0;
			 
	       buttons: buttonToNum
	         port map(
	           i_GClock => i_GClock,
	           i_in0 => int_in0,
	           i_in1 => int_in1,
	           i_GReset => i_GReset,
	           o_Aout => int_Aout,
	           o_Bout => int_Bout,
	           o_finished => int_finished
	         );
	         
	         adder: fullSys
	           port map(
	             i_GClock => int_fullSysClock,
	             i_GReset => i_GReset,
	             i_signA => int_signA,
	             i_exponentA => int_exponentA,
	             i_mantissaA => int_mantissaA,
	             i_signB => int_signB,
	             i_exponentB => int_exponentB,
	             i_mantissaB => int_mantissaB,
	             o_overflow => int_overflow,
	             o_sum => int_sum
	           );
				  
				aorb: nMux2In
					generic map(n=>16)
					port map(
						i_op0 => int_Aout,
						i_op1 => int_Bout,
						i_choice => i_ABSwitch,
						o_out => int_AorB
					);
					
				ABorS: nMux2In
					generic map(n=>16)
					port map(
						i_op0 => int_sum,
						i_op1 => int_AorB,
						i_choice => i_SSwitch,
						o_out => int_ABorS
					);
	           
	           o_ledsOut <= int_ABorS;
	           o_overflow <= int_overflow;
				  
				  o_inputDone <= int_finished;
	           end rtl;