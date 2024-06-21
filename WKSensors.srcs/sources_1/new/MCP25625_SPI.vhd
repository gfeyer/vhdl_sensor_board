library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  -- Standard logic vector definitions
use IEEE.NUMERIC_STD.ALL;     -- For numeric operations including unsigned and to_integer

entity MCP25625_SPI is
    Port (
        clk   : in std_logic;
        reset : in std_logic;
        start : in std_logic;                 -- Start signal for sending data
        num_bytes : in std_logic_vector(1 downto 0); -- Number of bytes to send (01, 10, 11)
        data_in : in std_logic_vector(23 downto 0);  -- Input data (up to 3 bytes)
        mosi  : out std_logic;
        miso  : in std_logic;
        sck   : buffer std_logic;
        ss    : out std_logic;
        ready : out std_logic                 -- Indicates ready to send/receive
    );
end MCP25625_SPI;

architecture Behavioral of MCP25625_SPI is
    type state_type is (idle, pre_send, send_data, post_send, done);
    signal state, next_state : state_type;
    signal byte_count : integer range 0 to 3 := 0;
    signal bit_index : integer range 0 to 7 := 0;
    signal sck_last : std_logic := '1';
    signal data_buffer : std_logic_vector(23 downto 0);
begin
    -- SPI Clock and Reset Management
    sck_process: process(clk, reset)
    begin
        if reset = '1' then
            sck <= '1';  -- Assume sck idles high
            sck_last <= '1';
        elsif rising_edge(clk) then
            if state /= idle then
                sck_last <= sck;  -- Update last sck state
                sck <= not sck;  -- Toggle sck every clock cycle
            end if;
        end if;
    end process;

    -- Main State Machine Logic
    sm_process: process(clk, reset)
    begin
        if reset = '1' then
            state <= idle;
            ss <= '1';  -- Deselect slave on reset
            ready <= '1';  -- Indicate ready on reset
        elsif rising_edge(clk) then
            state <= next_state;  -- Transition states
            -- Ensure ss and ready are correctly managed
            case next_state is
                when idle =>
                    ss <= '1';  -- Ensure slave is deselected in idle
                    ready <= '1';  -- System is ready in idle state
                when pre_send =>
                    ss <= '0';  -- Select slave when loading data
                    ready <= '0';  -- System is not ready when active
                when send_data =>
                    ss <= '0';  -- Keep slave selected during data transmission
                    ready <= '0';  -- System is busy
                when post_send =>
                    ss <= '0';  -- Select slave when loading data
                    ready <= '0';  -- System is not ready when active
                when done =>
                    ss <= '1';  -- Deselect slave when done
                    ready <= '1';  -- System becomes ready again
            end case;
        end if;
    end process;

    -- State Machine Transitions and Logic
    process(state, start, sck, sck_last)
    begin
        next_state <= state;  -- Default state hold
        case state is
            when idle =>
                ready <= '1';
                if start = '1' then
                    data_buffer <= data_in;  -- Load the input data
                    byte_count <= to_integer(unsigned(num_bytes));
                    bit_index <= 7;
                    next_state <= pre_send;
                end if;

            when pre_send =>
                ready <= '0';
                next_state <= send_data;

            when send_data =>
                if sck = '0' and sck_last = '1' then  -- Check for falling edge of sck
                    ss <= '0';  -- Select slave
                    mosi <= data_buffer(bit_index + 8 * (byte_count - 1));  -- Send MSB first
                    if bit_index = 0 then
                        bit_index <= 7;  -- Reset bit index
                        if byte_count = 1 then
                            next_state <= post_send;
                        else
                            byte_count <= byte_count - 1;
                        end if;
                    else
                        bit_index <= bit_index - 1;  -- Decrement bit index
                    end if;
                end if;
            
            when post_send =>
                -- this state adds a clock delay, so that the last bit is read on rising edge
                next_state <= done;
                
            when done =>
                ss <= '1';  -- Deselect slave
                ready <= '1';
                next_state <= idle;  -- Return to idle
        end case;
    end process;
    
end Behavioral;

