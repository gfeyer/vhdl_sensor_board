library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;  -- For numeric conversions

ENTITY MCP25625_SPI_TB IS
END MCP25625_SPI_TB;

ARCHITECTURE behavior OF MCP25625_SPI_TB IS 

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT MCP25625_SPI
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         start : IN  std_logic;
         num_bytes : IN  std_logic_vector(1 downto 0);
         data_in : IN  std_logic_vector(23 downto 0);
         mosi : OUT  std_logic;
         miso : IN  std_logic;
         sck : buffer  std_logic;
         ss : OUT  std_logic;
         ready : OUT  std_logic
        );
    END COMPONENT;
    
   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal start : std_logic := '0';
   signal num_bytes : std_logic_vector(1 downto 0) := (others => '0');
   signal data_in : std_logic_vector(23 downto 0) := (others => '0');
   signal miso : std_logic := '0';

   --Outputs
   signal mosi : std_logic;
   signal sck : std_logic;
   signal ss : std_logic;
   signal ready : std_logic;

   -- Clock period definition
   constant clk_period : time := 10 ns;

BEGIN

   -- Instantiate the Unit Under Test (UUT)
   uut: MCP25625_SPI PORT MAP (
          clk => clk,
          reset => reset,
          start => start,
          num_bytes => num_bytes,
          data_in => data_in,
          mosi => mosi,
          miso => miso,
          sck => sck,
          ss => ss,
          ready => ready
        );

   -- Clock process definitions
   clk_process :process
   begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
   end process;

   -- Stimulus process
   stim_proc: process
   begin        
      -- Initialize Inputs
      reset <= '1';
      wait for 30 ns;  -- Hold reset for 10 ns
      reset <= '0';
      wait for 20 ns;
      
      -- Setup data and number of bytes
      num_bytes <= "01";  -- Set to send 3 bytes
      data_in <= x"00_00_AA";  -- Data to send
      wait for clk_period*2;
      
      -- Start transmission
      start <= '1';
      wait for clk_period;
      start <= '0';

      -- Wait for transmission to complete
      wait until ready = '1';
      
      -- Send new data to SPI
      num_bytes <= "10";  -- Set to send 1 bytes
      data_in <= x"00_AA_BB";  -- Data to send
      wait for clk_period*2;
      -- Start transmission
      start <= '1';
      wait for clk_period;
      start <= '0';
      
      -- Wait for transmission to complete
      wait until ready = '1';
      
      -- Send new data to SPI
      num_bytes <= "11";  -- Set to send 1 bytes
      data_in <= x"AA_BB_CC";  -- Data to send
      wait for clk_period*2;
      -- Start transmission
      start <= '1';
      wait for clk_period;
      start <= '0';
      
      -- Wait for transmission to complete
      wait until ready = '1';

      -- End simulation
      wait;
   end process;

END;
