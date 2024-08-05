library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Debouncer is
    Port (
        Clk : in std_logic; -- input 
        Brake_depressed_switch_t1 : in std_logic; -- input
        Hidden_switch_t1 : in std_logic; -- input
        Ignition_switch_t1 : in std_logic; -- input
        Driver_door_t1 : in std_logic; -- input
        Passenger_door_t1 : in std_logic; -- input
        Reprogram_t1 : in std_logic; -- input
        Brake_depressed_switch_t2 : out std_logic; -- output
        Hidden_Switch_t2 : out std_logic; -- output
        Ignition_switch_t2 : out std_logic; -- output
        Driver_door_t2 : out std_logic; -- output
        Passenger_door_t2 : out std_logic; -- output
        Reprogram_t2 : out std_logic -- output
    );
end Debouncer;

architecture Behavioral of Debouncer is
    -- new type for counting
    type Debounce_Count_Array is array (0 to 5) of natural range 0 to 6500;
    -- signal to count the mounts of clocks that is in each put was stable
    signal Debounce_Count : Debounce_Count_Array := (others => 0);
    -- saving value of inputs in previous clock
    signal Debounce_State_Vector : std_logic_vector(5 downto 0) := (others => '0');

begin
    -- Debounce counter process
    process (Clk)
    begin
            for i in 0 to 5 loop
                if ( -- check each input to do not have any changes 
                    (i = 0 and Brake_depressed_switch_t1 /= Debounce_State_Vector(i)) or
                    (i = 1 and Hidden_switch_t1 /= Debounce_State_Vector(i)) or
                    (i = 2 and Ignition_switch_t1 /= Debounce_State_Vector(i)) or
                    (i = 3 and Driver_door_t1 /= Debounce_State_Vector(i)) or
                    (i = 4 and Passenger_door_t1 /= Debounce_State_Vector(i)) or
                    (i = 5 and Reprogram_t1 /= Debounce_State_Vector(i))
                ) then
                    -- State change detected, reset counter
                    Debounce_Count(i) <= 0;
                    -- put new value in debunce state vector
                    case i is
                      when 0 =>
                        Debounce_State_Vector(i) <= Brake_depressed_switch_t1;
                      when 1 =>
                        Debounce_State_Vector(i) <= Hidden_switch_t1;
                      when 2 =>
                        Debounce_State_Vector(i) <= Ignition_switch_t1;
                      when 3 =>
                        Debounce_State_Vector(i) <= Driver_door_t1;
                      when 4 =>
                        Debounce_State_Vector(i) <= Passenger_door_t1;
                      when 5 =>
                        Debounce_State_Vector(i) <= Reprogram_t1;
                      when others =>
                          null;
                  end case;
                 
                elsif Debounce_Count(i) = 6500 then
                    -- Stable state for 6500 cycles , update output
                    -- ( 6500 is equal with 0.1 second)
                    case i is
                        when 0 =>
                            Brake_depressed_switch_t2 <= Brake_depressed_switch_t1;
                        when 1 =>
                            Hidden_Switch_t2 <= Hidden_switch_t1;
                        when 2 =>
                            Ignition_switch_t2 <= Ignition_switch_t1;
                        when 3 =>
                            Driver_door_t2 <= Driver_door_t1;
                        when 4 =>
                            Passenger_door_t2 <= Passenger_door_t1;
                        when 5 =>
                            Reprogram_t2 <= Reprogram_t1;
                        when others =>
                            null;
                    end case;
                else
                    -- Increment counter
                    Debounce_Count(i) <= Debounce_Count(i) + 1;
                end if;
            end loop;
    end process;
end Behavioral;