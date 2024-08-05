library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity timer_tb is
end timer_tb;

architecture Behavioral of timer_tb is
  -- add all parts of code as a component
  component divider is
     port(
          clk_in : in STD_LOGIC;
          start_timer : in STD_LOGIC;
          en_1hz : out STD_LOGIC
     );
  end component divider;

  component time_parameters is
    Port ( 
        clk : in STD_LOGIC;
        Reprogram_t2 : in STD_LOGIC;
        param_select : in STD_LOGIC_VECTOR (1 downto 0);
        time_value : in STD_LOGIC_VECTOR (3 downto 0);
        interval : in STD_LOGIC_VECTOR (1 downto 0);
        param_out : out STD_LOGIC_VECTOR (3 downto 0)
    );
  end component time_parameters;

  component timer is
    port (
      clk_in : in STD_LOGIC;
      start_timer : in STD_LOGIC;
      time_inp : in STD_LOGIC_VECTOR(3 downto 0);
      en_1hz : in STD_LOGIC;
      expired : out STD_LOGIC
    );
  end component timer;

  component synchronize is
    generic (
        NSYNC : integer := 2
    );
    port (
        clk  : in  std_logic;
        Break_depressed_switch  : in  std_logic;
        Hidden_switch           : in  std_logic;
        Ignition_switch         : in  std_logic;
        Driver_door             : in  std_logic;
        Passenger_door          : in  std_logic;
        Reprogram               : in  std_logic;
        Break_depressed_switch_t1  : out  std_logic;
        Hidden_switch_t1           : out  std_logic;
        Ignition_switch_t1         : out  std_logic;
        Driver_door_t1             : out  std_logic;
        Passenger_door_t1          : out  std_logic;
        Reprogram_t1               : out  std_logic
    );
  end component synchronize;

  component Fuel_Pump_Logic is
    port (
        Brake_depressed_switch_t2 : in  std_logic;
        Hidden_Switch_t2         : in  std_logic;
        Ignition_switch_t2       : in  std_logic;
        Fuel_Pump_Power       : out std_logic
    );
  end component Fuel_Pump_Logic;

  component Debouncer is
    port (
      Clk                 : in  std_logic;
      Brake_depressed_switch_t1 : in  std_logic;
      Hidden_switch_t1         : in  std_logic;
      Ignition_switch_t1       : in  std_logic;
      Driver_door_t1           : in  std_logic;
      Passenger_door_t1        : in  std_logic;
      Reprogram_t1             : in  std_logic;
      Brake_depressed_switch_t2 : out std_logic;
      Hidden_Switch_t2         : out std_logic;
      Ignition_switch_t2       : out std_logic;
      Driver_door_t2           : out std_logic;
      Passenger_door_t2        : out std_logic;
      Reprogram_t2             : out std_logic
    );
  end component Debouncer;

  component StateMachine is
    Port (
        clk                : in  std_logic;
        ignition_switch_t2 : in  std_logic;
        Driver_door_t2     : in  std_logic;
        passenger_door_t2  : in  std_logic;
        reprogram_t2       : in  std_logic;
        expired            : in  std_logic;
        en_1hz             : in  std_logic;
        interval           : out std_logic_vector (1 downto 0);
        start_timer        : out std_logic;
        status_indicator   : out std_logic;
        sound_play         : out std_logic
    );
  end component StateMachine;

  component SineWaveGenerator is
  port(
      clk: in std_logic;
      sound_play : in std_logic;
      Siren_out: out std_logic
  );
  end component SineWaveGenerator;
  -- input for madulse
  signal clk : STD_LOGIC := '0';
  signal Break_depressed_switch  : std_logic := '0';
  signal Hidden_switch           : std_logic := '0';
  signal Ignition_switch         : std_logic := '0';
  signal Driver_door             : std_logic := '0';
  signal Passenger_door          : std_logic := '0';
  signal Reprogram               : std_logic := '0';
  signal Time_parameter_select   : STD_LOGIC_VECTOR (1 downto 0);
  signal time_value              : STD_LOGIC_VECTOR (3 downto 0);

  -- output for madules
  signal Siren_out       : std_logic; 
  signal status_indicator : std_logic;
  signal Fuel_Pump_Power  : std_logic;

  -- output for sinchronizer and debuncer
  signal Break_depressed_switch_t1  : std_logic := '0';
  signal Hidden_switch_t1           : std_logic := '0';
  signal Ignition_switch_t1         : std_logic := '0';
  signal Driver_door_t1             : std_logic := '0';
  signal Passenger_door_t1          : std_logic := '0';
  signal Reprogram_t1               : std_logic := '0';

  -- debuncer output
  signal Break_depressed_switch_t2  : std_logic := '0'; -- input for fuel pump
  signal Hidden_switch_t2           : std_logic := '0'; -- input for fuel pump
  signal Ignition_switch_t2         : std_logic := '0'; -- input for fuel pump and FSM
  signal Driver_door_t2             : std_logic := '0'; -- input for FSM
  signal Passenger_door_t2          : std_logic := '0'; -- input for FSM
  signal Reprogram_t2               : std_logic := '0'; -- input for FSM and time parameter

  signal sound_play                 : std_logic := '0'; -- output of FSM and input for silent
  signal start_timer                : std_logic; -- output of FSM and input for timer and devider
  signal interval : std_logic_vector (1 downto 0); -- FSM output and input for time parameter


  signal expired                    : std_logic; -- output of timer and input for FSM
  signal value                      : std_logic_vector (3 downto 0); -- input for timer and output for timer parameter
  signal en_1hz                     : std_logic; -- output of devider and input for FSM and timer

  constant CLK_PERIOD : time := 20 ns;
begin

  clk <= not clk after CLK_PERIOD / 2;
  -- simulation to achived different state in FSM
  Reprogram <= '1' after 10 ns,'0' after 20 ns ,'1' after 30 ns , '0' after 3 ms;    
  Time_parameter_select <= "00" after 10 ns, "01" after 20 ns, "00" after 40 ns, "01" after 150 us , "10" after 250 us ,"11" after 350 us ; 
  time_value <= "0001" after 10 ns, "1011" after 20 ns, "0001" after  40 ns, "0010" after  160 us, "0011" after  260 us, "0100" after  360 us; 
  
  Break_depressed_switch <= '1' after 20 ns, '0' after 40 ns , '1' after 1 ms , '0' after 1.5 ms,'1' after (1.5 ms + 60 us);
  Hidden_switch <= '1' after 30 ns, '0' after 40 ns , '1'  after 1 ms, '0' after 2 ms ;        
  Ignition_switch <= '1' after 10 ns, '0' after 2 ms , '1' after 14.5 ms ,'0' after 15 ms  ;  
  
  Driver_door <= '1' after 2.5 ms, '0' after 3.5 ms,'1'  after 5 ms , '0' after 8 ms ,'1' after 16 ms , '0' after 17 ms ;           
  Passenger_door <= '1' after 6 ms, '0' after 7 ms , '1' after 14 ms ,'0' after 18 ms ;        

  -- port binding
  u1: divider port map (clk_in => clk, start_timer => start_timer, en_1hz => en_1hz);
  u2: time_parameters port map(clk => clk, Reprogram_t2 => Reprogram_t2, param_select => Time_parameter_select, time_value => time_value, interval => interval, param_out => value);
  u3: timer port map (clk_in => clk, start_timer => start_timer, time_inp => value, en_1hz => en_1hz, expired => expired);
  u4: Fuel_Pump_Logic port map(Brake_depressed_switch_t2 => Break_depressed_switch_t2, Hidden_Switch_t2 => Hidden_switch_t2, Ignition_switch_t2 => Ignition_switch_t2, Fuel_Pump_Power => Fuel_Pump_Power);
  u5: synchronize port map ( clk => clk, Break_depressed_switch => Break_depressed_switch, Hidden_switch => Hidden_switch, Ignition_switch => Ignition_switch, Driver_door => Driver_door, Passenger_door => Passenger_door, Reprogram => Reprogram, Break_depressed_switch_t1 => Break_depressed_switch_t1, Hidden_switch_t1 => Hidden_switch_t1, Ignition_switch_t1 => Ignition_switch_t1, Driver_door_t1 => Driver_door_t1, Passenger_door_t1 => Passenger_door_t1, Reprogram_t1 => Reprogram_t1);
  u6: Debouncer port map (Clk => clk, Brake_depressed_switch_t1 => Break_depressed_switch_t1, Hidden_switch_t1 => Hidden_switch_t1, Ignition_switch_t1 => Ignition_switch_t1, Driver_door_t1 => Driver_door_t1, Passenger_door_t1 => Passenger_door_t1, Reprogram_t1 => Reprogram_t1, Brake_depressed_switch_t2 => Break_depressed_switch_t2, Hidden_Switch_t2 => Hidden_switch_t2, Ignition_switch_t2 => Ignition_switch_t2, Driver_door_t2 => Driver_door_t2, Passenger_door_t2 => Passenger_door_t2, Reprogram_t2 => Reprogram_t2);
  u7: StateMachine port map (clk => clk, ignition_switch_t2 => Ignition_switch_t2, Driver_door_t2 => Driver_door_t2, passenger_door_t2 => Passenger_door_t2, reprogram_t2 => Reprogram_t2, expired => expired, en_1hz => en_1hz, interval => interval, start_timer => start_timer, status_indicator => status_indicator, sound_play => sound_play);
  u8: SineWaveGenerator port map (clk => clk, sound_play => sound_play, Siren_out => Siren_out);

end Behavioral;