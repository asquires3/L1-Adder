library ieee;
use ieee.std_logic_1164.all;


entity oneBitXor is
  
  port(
    i_a,i_b: in std_logic;
    o_out: out std_logic
);
end entity;

architecture basic of oneBitXor is
  begin
    o_out <= i_a xor i_b;
end architecture;

