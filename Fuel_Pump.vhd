library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Fuel_Pump_Logic is
    port (
        Brake_depressed_switch_t2 : in  std_logic; -- input
        Hidden_Switch_t2         : in  std_logic; -- input
        Ignition_switch_t2       : in  std_logic; -- input
        Fuel_Pump_Power       : out std_logic -- output
    );
end entity Fuel_Pump_Logic;

architecture Behavioral of Fuel_Pump_Logic is
begin
    process (Brake_depressed_switch_t2, Hidden_Switch_t2, Ignition_switch_t2)
    begin -- sensetive to inputs
        if Ignition_switch_t2 = '1' then -- check for open switch
            if Brake_depressed_switch_t2 = '1' and Hidden_Switch_t2 = '1' then
                -- check for break depressed switch and hidden switch are pressed
                Fuel_Pump_Power <= '1';  -- Fuel pump switch is turned on
            end if;
        else
            Fuel_Pump_Power <= '0';  -- fuel pump power turn off when ignittion switch is off
        end if;
    end process;
end architecture Behavioral;
