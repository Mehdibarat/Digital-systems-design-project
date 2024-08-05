library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity StateMachine is

    Port (
        clk                : in  std_logic; -- input 
        ignition_switch_t2 : in  std_logic; -- input
        Driver_door_t2     : in  std_logic; -- input
        passenger_door_t2  : in  std_logic; -- input
        reprogram_t2       : in  std_logic; -- input
        expired            : in  std_logic; -- input
        en_1hz             : in  std_logic; -- input
        interval           : out std_logic_vector(1 downto 0); -- output
        start_timer        : out std_logic; -- output
        status_indicator    : out std_logic; -- output
        sound_play         : out std_logic -- output
    );
end entity StateMachine;



architecture Behavioral of StateMachine is
    type state_type is (armed , triggredT_Driver_Delay_orT_Passenger_Delay ,
                        Sound_Alarm_Is_on , Disarmed , Timer_ForT_Alarm_On , 
                        Timer_ForT_Arm_Delay , Waiting_for_Driver_Take_Off , 
                        Door_Is_Open); -- type state 
    signal current_state : state_type := armed; -- to save current state
    signal indicator_count : bit := '0'; -- use to counting for changing status_indicators value
    signal flag_start : bit := '0'; -- flag to check that start timer turned on
    signal flag_expi : bit := '0'; -- flag to be sure that expired signal change this state
    signal internal_start_timer : std_logic := '0';  -- Internal signal for start_timer

begin
process(clk)  -- Use an edge-triggered process for state transitions

begin
    if rising_edge(clk) then
        case current_state is -- determine states
            when armed =>
                if en_1hz = '1' then -- counting to change status in indicator each 2 sec
                    indicator_count <= not indicator_count;
                end if;

                if indicator_count = '1' and en_1hz = '1' then 
                -- for turnning on status indicator each 2 sec   
                    status_indicator <= '1';

                else
                    status_indicator <= '0';  
                end if;

                sound_play <= '0'; -- in this case sound is off
                if Driver_door_t2 = '1' or passenger_door_t2 = '1' then
                    -- check for openning door 
                    current_state <= triggredT_Driver_Delay_orT_Passenger_Delay;

                elsif ignition_switch_t2 = '1' then -- check for turnning on
                    current_state <= Disarmed;    
                end if;

                flag_start <= '0';
                flag_expi <= '0';
                internal_start_timer <= '0';  -- Reset internal timer

            when triggredT_Driver_Delay_orT_Passenger_Delay =>
                status_indicator <= '1'; -- in this case status indicator is always on
                sound_play <= '0'; -- in this case sound is off

                if ignition_switch_t2 = '1' then -- check for turnning on
                    current_state <= Disarmed;    
                end if;


                if internal_start_timer = '1' then -- if start timer was 1 turn it off
                    internal_start_timer <= '0';  -- Reset internal timer
                end if;

                
                -- check expired flag to vector that expired achived in this case and it is not prev value
                if flag_expi = '1' then 
                    if expired = '1' then -- 
                        current_state <= Sound_Alarm_Is_on;
                    end if;
                end if;

                -- check to selecct delay time 
                if passenger_door_t2 = '1' and flag_start = '0' and reprogram_t2 = '0' then
                    interval <= "10";  -- Assuming interval is in unsigned format
                    internal_start_timer <= '1';
                    flag_start <= '1';
                    flag_expi <= '1';
                elsif Driver_door_t2 = '1' and flag_start = '0' and reprogram_t2 = '0' then
                    interval <= "01";  -- Assuming interval is in unsigned format
                    internal_start_timer <= '1';
                    flag_start <= '1';
                    flag_expi <= '1';    
                end if;


            when Sound_Alarm_Is_on =>
                status_indicator <= '1';
                sound_play <= '1'; 
                if Driver_door_t2 = '0' and passenger_door_t2 = '0' then -- check condition to change state
                    current_state <= Timer_ForT_Alarm_On;
                elsif ignition_switch_t2 = '1' then -- check condition to change state
                    current_state <= Disarmed;    
                end if;
                flag_start <= '0';
                flag_expi <= '0';

            when Timer_ForT_Alarm_On =>
                status_indicator <= '1';
                sound_play <= '1'; 

                if ignition_switch_t2 = '1' then -- check condition to change state
                    current_state <= Disarmed;    
                end if;

                

                if internal_start_timer = '1' then
                    internal_start_timer <= '0';  -- Reset internal timer
                end if;


                if flag_expi = '1' then
                    if expired = '1' then
                        current_state <= armed;
                    end if;
                end if;

                -- check expired flag to vector that expired achived in this case and it is not prev value
                if flag_start = '0' and reprogram_t2 = '0' then
                    interval <= "11";  -- Assuming interval is in unsigned format
                    internal_start_timer <= '1';
                    flag_start <= '1';
                    flag_expi <= '1';
                end if;

            when Disarmed =>
                status_indicator <= '0';
                sound_play <= '0'; 
                if ignition_switch_t2 = '0' then
                    current_state <= Waiting_for_Driver_Take_Off;    
                end if;

            when Waiting_for_Driver_Take_Off =>
                status_indicator <= '0';
                sound_play <= '0'; 

                if Driver_door_t2 = '1' then -- check to openning door then change current state
                    current_state <= Door_Is_Open;    
                end if;

            when Door_Is_Open =>
                status_indicator <= '0';
                sound_play <= '0'; 

                if Driver_door_t2 = '0' and passenger_door_t2 = '0' then -- check to be sure that all doors are closed
                    current_state <= Timer_ForT_Arm_Delay;    
                end if;

                flag_start <= '0';
                flag_expi <= '0';

            when Timer_ForT_Arm_Delay =>
                status_indicator <= '0';
                sound_play <= '0'; 

                if internal_start_timer = '1' then
                    internal_start_timer <= '0';  -- Reset internal timer
                end if;

                if flag_expi = '1' then
                    if expired = '1' then
                        current_state <= armed;
                    end if;
                end if;

                if flag_start = '0' and reprogram_t2 = '0' then
                    interval <= "00";  -- Assuming interval is in unsigned format
                    internal_start_timer <= '1';
                    flag_start <= '1';
                    flag_expi <= '1';
                end if;

            when others =>
                current_state <= armed;  -- Reset on unexpected state
        end case;
    end if;
end process;

start_timer <= internal_start_timer;  -- Drive the output port from the internal signal
end Behavioral;