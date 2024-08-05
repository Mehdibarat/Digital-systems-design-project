library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SineWaveGenerator is
    port(
        clk: in std_logic;      -- input
        sound_play : in std_logic ; -- input signal as a switch on or off
        Siren_out: out std_logic    -- output signal to used in speaker
    );
end entity SineWaveGenerator;

architecture Behavioral of SineWaveGenerator is
    signal counter: integer := 0; -- counter to decide output value
    signal frequency: integer := 400;  -- frequency of output signal
    signal increasing: std_logic := '1';  -- flag to determine increasing or decreasing frequency
    
begin
    process(clk)
    begin
        if rising_edge(clk)  and sound_play = '1' then
            counter <= counter + 1;
            if counter = 65536/frequency then 
                if frequency = 700 then
                    increasing <= '0';  -- change flag to decreasing frequency
                elsif frequency = 400 then 
                    increasing <= '1';  -- change flag to increasing frequency
                end if;
                
                if increasing = '1' then
                    frequency <= frequency + 1;  -- increasing frequency
                else
                    frequency <= frequency - 1;  -- decreasing frequency
                end if;
                
                counter <= 0;
            end if;
            
            if counter < (65536/frequency)/2 then  -- change to create periodic signal
                Siren_out <= '1';
            else
                Siren_out <= '0';
            end if;
        
        elsif sound_play = '0' then -- when input is off output is off
            Siren_out <= '0';
        end if;
    end process;
end architecture Behavioral;
