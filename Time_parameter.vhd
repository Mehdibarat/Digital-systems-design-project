library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity time_parameters is
    Port ( 
        clk : in STD_LOGIC;
        Reprogram_t2 : in STD_LOGIC; -- signal to decide reprogram
        param_select : in STD_LOGIC_VECTOR (1 downto 0); -- select delay 
        time_value : in STD_LOGIC_VECTOR (3 downto 0); -- value for selected delay
        interval : in STD_LOGIC_VECTOR (1 downto 0); -- select delay to put it in param out
        param_out : out STD_LOGIC_VECTOR (3 downto 0) -- as input for timer 
    );
end time_parameters;


architecture Behavioral of time_parameters is
    -- defualt valuse for delays 
    signal T_ARM_DELAY : STD_LOGIC_VECTOR (3 downto 0) := "0110";
    signal T_DRIVER_DELAY : STD_LOGIC_VECTOR (3 downto 0) := "1000";
    signal T_PASSENGER_DELAY : STD_LOGIC_VECTOR (3 downto 0) := "1111";
    signal T_ALARM_ON : STD_LOGIC_VECTOR (3 downto 0) := "1010";
    signal temp : STD_LOGIC_VECTOR (3 downto 0) := "0000";
begin

    process(clk, Reprogram_t2)
    begin
            if Reprogram_t2 = '1' then -- check flag to change value sums of delay
                case param_select is
    
                    when "00" =>
                        T_ARM_DELAY <= time_value;
    
                    when "01" =>
                        T_DRIVER_DELAY <= time_value;
    
                    when "10" =>
                        T_PASSENGER_DELAY <= time_value;
    
                    when others =>
                        T_ALARM_ON <= time_value;
                end case;
          
            elsif(Reprogram_t2 = '0') then -- when FSM select a delay , send it to Timer
                case interval is
                    when "00" =>
                        temp  <= T_ARM_DELAY;
    
                    when "01" =>
                        temp <= T_DRIVER_DELAY;
    
                    when "10" =>
                        temp <= T_PASSENGER_DELAY;
    
                    when others =>
                        temp <= T_ALARM_ON;
                end case;
            end if;
    end process;
    param_out <= temp;
end Behavioral;