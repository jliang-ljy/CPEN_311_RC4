library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ksa is
  port(
    CLOCK_50            : in  std_logic;  -- Clock pin
    KEY                 : in  std_logic_vector(3 downto 0);  -- push button switches
    SW                 : in  std_logic_vector(9 downto 0);  -- slider switches
    LEDR                : out std_logic_vector(9 downto 0);  -- red lights
    HEX0                : out std_logic_vector(6 downto 0);
    HEX1                : out std_logic_vector(6 downto 0);
    HEX2                : out std_logic_vector(6 downto 0);
    HEX3                : out std_logic_vector(6 downto 0);
    HEX4                : out std_logic_vector(6 downto 0);
    HEX5                : out std_logic_vector(6 downto 0)
  );
end ksa;

architecture rtl of ksa is

    COMPONENT SevenSegmentDisplayDecoder IS
      PORT
      (
          ssOut : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
          nIn : IN STD_LOGIC_VECTOR (3 DOWNTO 0)
      );
    END COMPONENT;

    COMPONENT lab4_core
      PORT
      (
          clock : IN STD_LOGIC;
          start : IN STD_LOGIC;
          counter_value : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
          address : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
          finish : OUT STD_LOGIC;
          write_enable : OUT STD_LOGIC;
          switch: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
          out1: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
          out2: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
          out3: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
          out4: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
          out5: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
          out6: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
      );
    END COMPONENT;
   
    -- clock and reset signals  
    signal clk, reset_n : std_logic;
    signal start : std_logic;
    signal counter_value : std_logic_vector(7 downto 0);
    signal address : std_logic_vector(7 downto 0);
    signal finish : std_logic;
    signal write_enable : std_logic;
    signal switch: std_logic_vector(9 downto 0);
    signal out1: std_logic_vector(3 DOWNTO 0);
    signal out2: std_logic_vector(3 DOWNTO 0);
    signal out3: std_logic_vector(3 DOWNTO 0);
    signal out4: std_logic_vector(3 DOWNTO 0);
    signal out5: std_logic_vector(3 DOWNTO 0);
    signal out6: std_logic_vector(3 DOWNTO 0);

begin
    switch <= SW; 
    clk <= CLOCK_50;
    reset_n <= KEY(3);
    start <= KEY(0);  -- assuming KEY(0) is used for the start signal

    -- Instantiation of lab4_core
    lab4_core_inst : lab4_core
        port map (
            clock => clk,
            start => start,
            counter_value => counter_value,
            address => address,
            finish => finish,
            write_enable => write_enable,
            switch => switch,
            out1 => out1,
            out2 => out2,
            out3 => out3,
            out4 => out4,
            out5 => out5,
            out6 => out6
            
        );

    SevenSegmentDisplayDecoder_inst1: SevenSegmentDisplayDecoder 
         port map(
         ssOut => HEX0,
         nIn => out1
         );
    
     SevenSegmentDisplayDecoder_inst2: SevenSegmentDisplayDecoder 
         port map(
         ssOut => HEX1,
         nIn => out2
         );
    
     SevenSegmentDisplayDecoder_inst3: SevenSegmentDisplayDecoder 
         port map (
         ssOut => HEX2,
         nIn => out3
         );

     SevenSegmentDisplayDecoder_inst4: SevenSegmentDisplayDecoder 
         port map (
         ssOut => HEX3,
         nIn => out4
         );

     SevenSegmentDisplayDecoder_inst5: SevenSegmentDisplayDecoder 
         port map(
        ssOut => HEX4,
         nIn => out5
         );
    
     SevenSegmentDisplayDecoder_inst6: SevenSegmentDisplayDecoder 
         port map(
         ssOut => HEX5,
         nIn => out6
         );
         
    -- Additional logic to use the outputs of lab4_core can be added here
    -- Example: connect counter_value to LEDR for display
    LEDR(7 downto 0) <= counter_value;
    LEDR(9 downto 8) <= (others => '0');  -- Unused LEDs set to 0

end rtl;



