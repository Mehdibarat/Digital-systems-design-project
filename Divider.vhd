library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity divider is

  port(
    clk_in : in STD_LOGIC;
    start_timer : in STD_LOGIC; -- using for reset timer 
    en_1hz : out STD_LOGIC  -- output to show 1 second
  );
end divider;


architecture Behavioral of divider is
  signal count : unsigned(15 downto 0) := (others => '0'); -- clock counter for 1 second
begin
  process (clk_in, start_timer)
  begin

    if start_timer = '1' then -- reset timer
      count <= (others => '0');
      en_1hz <= '0'; -- if time input was zero turn on expired 
    end if;

      if rising_edge(clk_in) then -- check for counting 
      if count = "1111111111111111" then
        en_1hz <= '1';
        count <= (others => '0');
      
      else
        count <= count + 1;
        en_1hz <= '0';
      end if;
    end if;
  end process;
end Behavioral;