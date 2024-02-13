
library ieee;
use ieee.std_logic_1164.all;

entity nBitAnder is 

  generic(
    n: integer := 2
);

  port(
    i_a, i_b : in std_logic_vector(n-1 downto 0);
    o_out :out std_logic_vector(n-1 downto 0)
  );
end entity;

architecture basic of nBitAnder is
  
  signal out_o : std_logic_vector(n-1 downto 0);
  
  component oneBitAnd
    port(
      i_a,i_b : in std_logic;
      o_out : out std_logic
  );
end component;
  begin
  nAnders: for i in 0 to n-1 generate
    oneBitAnd_K: oneBitAnd
      port map(
        i_a => i_a(i),
        i_b => i_b(i),
        o_out => out_o(i)
      );
  end generate nAnders;

o_out <= out_o;

end architecture;

