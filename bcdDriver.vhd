

library ieee;
use ieee.std_logic_1164.all;


--     -- 0
--  5 |  | 1
--     -- 6
--  4 |  | 2
--     -- 3
entity bcdDriver is 
  port(
    i_digit : in std_logic_vector(3 downto 0);
    o_bcd0, o_bcd1, o_bcd2, o_bcd3, o_bcd4, o_bcd5, o_bcd6 :out std_logic
  );
end entity;

architecture basic of bcdDriver is
  
  signal int_zero, int_one, int_two, int_three, int_four, int_five, int_six, int_seven, int_eight, int_nine : std_logic;
  
begin
  
  int_zero <= not i_digit(3) and not i_digit(2) and not i_digit(1) and not i_digit(0);
  int_one <= not i_digit(3) and not i_digit(2) and not i_digit(1) and i_digit(0);
  int_two <= not i_digit(3) and not i_digit(2) and i_digit(1) and not i_digit(0);
  int_three <= not i_digit(3) and not i_digit(2) and i_digit(1) and i_digit(0);
  int_four <= not i_digit(3) and i_digit(2) and not i_digit(1) and not i_digit(0);
  int_five <= not i_digit(3) and i_digit(2) and not i_digit(1) and i_digit(0);
  int_six <= not i_digit(3) and i_digit(2) and i_digit(1) and not i_digit(0);
  int_seven <= not i_digit(3) and i_digit(2) and i_digit(1) and i_digit(0);
  int_eight <= i_digit(3) and not i_digit(2) and not i_digit(1) and not i_digit(0);
  int_nine <= i_digit(3) and not i_digit(2) and not i_digit(1) and i_digit(0);
  
  --these need to be inverse since the light is high on a 0
  
  o_bcd0 <= not(not int_one and not int_four); --0,2,3,5,6,7,8,9 
  o_bcd1 <= not(not int_five and not int_six); --0,1,2,3,4,7,8,9
  o_bcd2 <= not(not int_two); --0,1,3,4,5,6,7,8,9
  o_bcd3 <= not(not int_one and not int_four and not int_seven and not int_nine); --0,2,3,5,6,8
  o_bcd4 <= not(int_two or int_six or int_eight or int_zero);
  o_bcd5 <= not(int_four or int_five or int_six or int_eight or int_nine or int_zero);
  o_bcd6 <= not(not int_one and not int_seven and not int_zero);
  
end architecture;