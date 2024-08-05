library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity synchronize is
    generic (
        NSYNC : integer := 2  -- تعداد فلیپ‌فلاپ‌های همگام‌ساز، باید حداقل 2 باشد
    );
    port (
        clk  : in  std_logic;
        Break_depressed_switch  : in  std_logic; -- input for synchronization
        Hidden_switch           : in  std_logic; -- input for synchronization
        Ignition_switch         : in  std_logic; -- input for synchronization
        Driver_door             : in  std_logic; -- input for synchronization
        Passenger_door          : in  std_logic; -- input for synchronization
        Reprogram               : in  std_logic; -- input for synchronization
        Break_depressed_switch_t1  : out std_logic; -- output after synchronization
        Hidden_switch_t1           : out std_logic; -- output after synchronization
        Ignition_switch_t1         : out std_logic; -- output after synchronization
        Driver_door_t1             : out std_logic; -- output after synchronization
        Passenger_door_t1          : out std_logic; -- output after synchronization
        Reprogram_t1               : out std_logic
    );
end entity synchronize;

architecture Behavioral of synchronize is
    -- signal to buffering value to avoid change near a clock time
    signal sync_b : std_logic_vector(NSYNC-2 downto 0); 
    -- signal to buffering value to avoid change near a clock time
    signal sync_h : std_logic_vector(NSYNC-2 downto 0);
    -- signal to buffering value to avoid change near a clock time
    signal sync_i : std_logic_vector(NSYNC-2 downto 0);
    -- signal to buffering value to avoid change near a clock time
    signal sync_d : std_logic_vector(NSYNC-2 downto 0);
    -- signal to buffering value to avoid change near a clock time
    signal sync_p : std_logic_vector(NSYNC-2 downto 0);
    -- signal to buffering value to avoid change near a clock time
    signal sync_r : std_logic_vector(NSYNC-2 downto 0);
begin

    process (clk)
    begin   
        -- put value sinchronized by clock
        sync_b <= sync_b(NSYNC-3 downto 0) & Break_depressed_switch;
        -- put value sinchronized by clock
        sync_h <= sync_h(NSYNC-3 downto 0) & Hidden_switch;
        -- put value sinchronized by clock
        sync_i <= sync_i(NSYNC-3 downto 0) & Ignition_switch;
        -- put value sinchronized by clock
        sync_d <= sync_d(NSYNC-3 downto 0) & Driver_door;
        -- put value sinchronized by clock
        sync_p <= sync_p(NSYNC-3 downto 0) & Passenger_door;
        -- put value sinchronized by clock
        sync_r <= sync_r(NSYNC-3 downto 0) & Reprogram;
    end process;

    -- put value to output after sinchronization
    Break_depressed_switch_t1 <= sync_b(NSYNC-2);
    -- put value to output after sinchronization
    Hidden_switch_t1 <= sync_h(NSYNC-2);
    -- put value to output after sinchronization
    Ignition_switch_t1  <= sync_i(NSYNC-2);
    -- put value to output after sinchronization
    Driver_door_t1  <= sync_d(NSYNC-2);
    -- put value to output after sinchronization
    Passenger_door_t1 <= sync_p(NSYNC-2);
    -- put value to output after sinchronization
    Reprogram_t1 <= sync_r(NSYNC-2);

end architecture Behavioral;