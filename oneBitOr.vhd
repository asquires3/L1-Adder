
library ieee;
use ieee.std_logic_1164.all;


entity oneBitOr is
  
  port(
    i_a,i_b: in std_logic;
    o_out: out std_logic
);
end entity;

architecture basic of oneBitOr is
  begin
    o_out <= i_a or i_b;
end architecture;
