library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity timer is
  port(
    clk_in : in STD_LOGIC;
    start_timer : in STD_LOGIC; -- start to counting 
    time_inp : in STD_LOGIC_VECTOR(3 downto 0); -- value for counting
    en_1hz : in STD_LOGIC; -- input signal for 1 second
    expired : out STD_LOGIC -- flag for expired time
  );
end timer;

architecture Behavioral of timer is
  signal count : unsigned(3 downto 0); -- temporary variable for save time
  signal decrements : STD_LOGIC; -- to decide decrementing count
begin 
  process (clk_in) -- decrement 1 cycle aghab tare  bekhater in process
  begin

    if start_timer = '1' then -- check for start counting
      expired <= '0'; -- turning off expired flag
       if unsigned(time_inp) = 0 then -- checking for zero input avoiding of more counting
         count <= "0001" ;
         expired <= '1';
       else 
         count <= unsigned(time_inp); -- set new value for count
       end if ;
      decrements <= '0';

    elsif en_1hz = '1' then -- check 1 second flag
      decrements <= '1';

    else
      decrements <= '0';
    end if;
    
    if decrements = '1' then
      if count = 1 then -- check for last second of timer
        expired <= '1';

      else
        count <= count - 1;
        expired <= '0';
      end if;

      decrements <= '0';
    end if;
  end process;
end Behavioral;