library ieee;
use ieee.std_logic_1164.all;


entity oneBitAnd is
  
  port(
    i_a,i_b: in std_logic;
    o_out: out std_logic
);
end entity;

architecture basic of oneBitAnd is
  begin
    o_out <= i_a and i_b;
end architecture;