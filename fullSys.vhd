library ieee;
use ieee.std_logic_1164.all;

ENTITY fullSys IS

  PORT(
      i_signA, i_signB, i_GClock, i_GReset : in std_logic;
      i_mantissaA, i_mantissaB : in std_logic_vector (7 downto 0);
      i_exponentA, i_exponentB : in std_logic_vector (6 downto 0);
      o_overflow : out std_logic;
      o_sum : out std_logic_vector(15 downto 0)
	  );
	  
END ENTITY fullSys;

architecture rtl of fullSys is

  signal int_expDifferenceOut : std_logic_vector (6 downto 0);
  
  signal int_loadRShiftReg, int_shiftRShiftReg, int_shiftIn : std_logic;
  signal int_smallerMantissa, int_largerMantissa : std_logic_vector(7 downto 0);
  signal int_RShiftIn, int_RShiftOut, int_largerMantAppended : std_logic_vector(8 downto 0);
  
  signal int_LRRegRout, int_LRRegLout, int_LRRegOut : std_logic_vector(9 downto 0);
  signal int_loadLRReg, int_shiftLRReg, int_shiftDir : std_logic;
  
  signal int_Ain, int_Bin, int_Aout, int_Bout, int_finalOut : std_logic_vector(15 downto 0);
  signal int_largerExp, int_smallerExp : std_logic_vector(6 downto 0);
  signal int_loadExpDiff : std_logic;

  signal int_bigALUcout : std_logic;
  signal int_bigALUsout : std_logic_vector(8 downto 0);
  signal int_bigALUResult : std_logic_vector(9 downto 0);
  
  signal int_curState : std_logic_vector(6 downto 0);
  
  signal int_finalSign, int_sameSigns, int_notSameSigns, int_loadFinal : std_logic;
  signal int_finalVal : std_logic_vector(15 downto 0);

  signal int_sameExp : std_logic;
  signal int_AMlarger, int_MantSign, int_largerExpSign : std_logic;  

  signal int_incDecAction, int_incOrDec : std_logic;
  signal int_incDecMuxOut, int_incDecRegOut, int_incDeced : std_logic_vector(6 downto 0);
  signal int_loadA, int_loadB, int_loadIncDecReg : std_logic;
  
  signal int_ABcout, int_BAcout : std_logic;
  signal int_ABsout, int_BAsout : std_logic_vector(6 downto 0);
  
  component control
    port(
      i_clock, i_resetBar : in std_logic;
      i_expDiff : in std_logic_vector (6 downto 0);
      i_LRReg : in std_logic_vector(9 downto 0);
      i_bigALUResult : in std_logic_vector(9 downto 0);
      i_sameSign : in std_logic;
      
      o_loadA, o_loadB, o_loadExpDiff, 
        o_loadIncDecReg, o_incOrDecr, o_incDecAction, 
        o_shiftIn, o_loadRShiftReg, o_shiftRShiftReg, 
        o_shiftDir, o_loadLRReg, o_shiftLRReg, o_loadFinal : out std_logic;
      --o_resetCounter, o_enableCounter : out std_logic;
      o_curState : out std_logic_vector(6 downto 0)
    );
  
end component;
  
  	component shiftNbit
	  generic(n: integer;
	          shift: integer
	  );
	  port(i_clock, i_load, i_shift, i_resetBar : in std_logic;
              i_value : in std_logic_vector(n-1 downto 0);
              o_value : out std_logic_vector(n-1 downto 0));
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
	  
	  component nMux2In
	  generic(n: integer);
  PORT(
	    i_op0 : in std_logic_vector(n-1 downto 0);
	    i_op1 : in std_logic_vector(n-1 downto 0);
	    i_choice : in std_logic;
	    o_out : out std_logic_vector(n-1 downto 0)
	  );
	  end component;
	  
	  component mux1bit
	    
  PORT(
	    i_op0 : in std_logic;
	    i_op1 : in std_logic;
	    i_choice : in std_logic;
	    o_out : out std_logic
	  );
	  end component;
	  
	  begin
	    
	    int_sameSigns <= int_Aout(15) xnor int_Bout(15);
	    
	    int_Ain <= i_signA & i_exponentA & i_mantissaA;
	    int_Bin <= i_signB & i_exponentB & i_mantissaB;
	    
	    int_sameExp <= int_ABcout and int_BAcout;
	    
	    controller: control	    
    port map(
      i_clock => i_GClock, 
      i_resetBar => i_GReset,
      i_expDiff => int_expDifferenceOut,
      i_LRReg => int_LRRegOut,
      i_bigALUResult => int_bigALUResult,
      i_sameSign => int_sameSigns,
      
      o_loadA => int_loadA, 
      o_loadB => int_loadB, 
      o_loadExpDiff => int_loadExpDiff,
      o_loadIncDecReg => int_loadIncDecReg, 
      o_incOrDecr => int_incOrDec, 
      o_incDecAction => int_incDecAction, 
      o_shiftIn => int_shiftIn, 
      o_loadRShiftReg => int_loadRShiftReg, 
      o_shiftRShiftReg => int_shiftRShiftReg, 
      o_shiftDir => int_shiftDir, 
      o_loadLRReg => int_loadLRReg, 
      o_shiftLRReg => int_shiftLRReg, 
      o_loadFinal => int_loadFinal,
      --o_resetCounter, 
      --o_enableCounter 
      o_curState => int_curState
    );
	    
	    regA: shiftNBit
	         generic map(n=>16, shift=>1)
	         port map(
	           i_clock => i_GClock,
	           i_resetBar => i_GReset,
	           i_load => int_loadA,
	           i_shift => '0',
	           i_value => int_Ain,
	           o_value => int_Aout
	         );
	         
	     regB: shiftNBit
	         generic map(n=>16, shift=>1)
	         port map(
	           i_clock => i_GClock,
	           i_resetBar => i_GReset,
	           i_load => int_loadB,
	           i_shift => '0',
	           i_value => int_Bin,
	           o_value => int_Bout
	         );
	       
	    --if subtracting larger from smaller we get 
	    ABExpSub: nFullAdderSubtractor
	     generic map(n=>7)
	     port map(
	       i_subControl => '1',
	       i_a => int_Aout(14 downto 8),
	       i_b => int_Bout(14 downto 8),
	       o_carryOut => int_ABcout,
	       o_sumOut => int_ABsout
	     );
	     
	     BAExpSub: nFullAdderSubtractor
	       generic map(n=>7)
	       port map(
	         i_subControl =>'1',
	         i_a => int_Bout(14 downto 8),
	         i_b => int_Aout(14 downto 8),
	         o_carryOut => int_BAcout,
	         o_sumOut => int_BAsout
	       );
	       
	      --if there is a carry out, then the smaller was subtracted from the larger 
	      expChoice: nMux2In
	       generic map(n=>7)
	       port map(
	         i_op0 => int_BAsout,
	         i_op1 => int_ABsout,
	         i_choice => int_ABcout, --if 1 then Aexp is larger than Bexp
	         o_out => int_expDifferenceOut
	       );
	       
	       largerExp: nMux2In
	         generic map(n=>7)
	         port map(
	           i_op0 => int_Bout(14 downto 8),
	           i_op1 => int_Aout(14 downto 8),
	           i_choice => int_ABcout,
	           o_out => int_largerExp
	         );
	         
	       smallerExp: nMux2In
	         generic map(n=>7)
	         port map(
	           i_op0 => int_Aout(14 downto 8),
	           i_op1 => int_Bout(14 downto 8),
	           i_choice => int_ABcout,
	           o_out => int_smallerExp
	         );
	         
	       largerMant: nMux2In
	         generic map(n=>8)
	         port map(
	           i_op0 => int_Bout(7 downto 0),
	           i_op1 => int_Aout(7 downto 0),
	           i_choice => int_ABcout,
	           o_out => int_largerMantissa
	         );
	         
	       smallerMant: nMux2In
	         generic map(n=>8)
	         port map(
	           i_op0 => int_Aout(7 downto 0),
	           i_op1 => int_Bout(7 downto 0),
	           i_choice => int_ABcout,
	           o_out => int_smallerMantissa          
	         );
	       
	       
	      int_RShiftIn <= '1' & int_smallerMantissa;
	       
	       rShiftReg: shiftNBitArithm
        generic map(n=>9, shift=>1)
        port map(
          i_clock => i_GCLock, 
          i_load => int_loadRShiftReg, 
          i_shift => int_shiftRShiftReg, 
          i_resetBar => i_GReset, 
          i_shiftIn => '0',
          i_value => int_RShiftIn,
          o_value => int_RShiftOut
        );
	       
	       int_largerMantAppended <= '1' & int_largerMantissa;
	       int_notSameSigns <= not int_sameSigns;
	       bigALU: nFullAdderSubtractor
	       generic map(n=>9)
	       port map(
	         i_subControl => int_notSameSigns,
	         i_a => int_largerMantAppended,
	         i_b => int_RShiftOut,
	         o_carryOut => int_BigALUcout,
	         o_sumOut => int_BigALUsout
	       );
	       
	       int_bigALUResult <= int_bigALUcout & int_bigALUsout;      
	       
	       incrDecrReg: shiftNBit
	         generic map(n=>7, shift=>1)
	         port map(
	           i_clock => i_GClock,
	           i_resetBar => i_GReset,
	           i_load => int_loadIncDecReg,
	           i_shift => '0',
	           i_value => int_incDecMuxOut,
	           o_value => int_incDecRegOut
	         );
	       
	       incDecMux: nMux2In
	         generic map(n=>7)
	         port map(
	           i_op0 => int_largerExp,
	           i_op1 => int_incDeced,
	           i_choice => int_incDecAction,
	           o_out => int_incDecMuxOut        
	         );  
	         
	       incDecALU: nFullAdderSubtractor
	         generic map(n=>7)
	         port map(
	           --1 for dec
	           i_subControl => int_incOrDec,
	           i_a => int_incDecRegOut,
	           i_b => "0000001",
	           o_sumOut => int_incDeced
	         );
	       
	       largerMantissaALU: nFullAdderSubtractor
	         generic map(n=>8)
	         port map(
	           i_subControl => '1',
	           i_a => int_Aout(7 downto 0),
	           i_b => int_Bout(7 downto 0),
	           o_carryOut => int_AMlarger
	         );
	         
	         --secondary deciding characteristic for the sign, used if exponents are equal, look at the mantissa
	       largerMantMuxForSign: mux1bit
	         port map(
	           i_op0 => int_Bout(15),
	           i_op1 => int_Aout(15),
	           i_choice => int_AMlarger,
	           o_out => int_MantSign
	         );
  
          largerExpMuxForSign: mux1bit
            port map(
              i_op0 => int_Bout(15),
              i_op1 => int_Aout(15),
              i_choice => int_ABcout,
              o_out => int_largerExpSign
            );
  	         
	         --main characteristic of sign, if one exponent is larger, use the sign from that one
	         finalSignMux: mux1bit
	           port map(
	             i_op0 => int_largerExpSign,
	             i_op1 => int_MantSign,
	             i_choice => int_sameExp,
	             o_out => int_finalSign
	           );
	          
	          
	          int_finalVal <= int_finalSign & int_incDecRegOut & int_LRRegOut(7 downto 0);
	          finalReg: shiftNBit
	         generic map(n=>16, shift=>1)
	         port map(
	           i_clock => i_GClock,
	           i_resetBar => i_GReset,
	           i_load => int_loadFinal,
	           i_shift => '0',
	           i_value => int_finalVal,
	           o_value => int_finalOut
	         );
	           
	           
	         LRRegL:  shiftNBitArithm
        generic map(n=>10, shift=>-1)
        port map(
          i_clock => i_GClock, 
          i_load => int_loadLRReg, 
          i_shift => int_shiftLRReg, 
          i_resetBar => i_GReset, 
          i_shiftIn => '0',
          i_value => int_bigALUResult,
          o_value => int_LRRegLout
        );
        
        LRRegR:  shiftNBitArithm
        generic map(n=>10, shift=>1)
        port map(
          i_clock => i_GClock, 
          i_load => int_loadLRReg, 
          i_shift => int_shiftLRReg, 
          i_resetBar => i_GReset, 
          i_shiftIn => '0',
          i_value => int_bigALUResult,
          o_value => int_LRRegRout
        );
        
	         LRRegisterMux: nMux2In
	           generic map(n=>10)
	           port map(
	             --if the signs are the same then the exponent can only increase, and the mantissa can only shift left
	             i_op0 => int_LRRegLout,
	             i_op1 => int_LRRegRout,
	             i_choice => int_sameSigns,
	             o_out => int_LRRegOut
	           );
	           
	           o_sum <= int_finalOut;
	           
	       end rtl;