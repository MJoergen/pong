library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- This controls the computer

entity computer is

    generic (
                SIMULATION : boolean := false;
                FREQ       : integer := 25000000 -- Input clock frequency
            );
    port (
             -- Clock
             clk_i      : in  std_logic;  -- 25 MHz
             clk_vs_i   : in  std_logic;  -- 60 Hz

             -- Input control
             ball_x_i   : in  std_logic_vector (10 downto 0);
             ball_y_i   : in  std_logic_vector (10 downto 0);

             -- Display
             pixel_x_i  : in  std_logic_vector (10 downto 0);
             pixel_y_i  : in  std_logic_vector (10 downto 0);
             rgb_i      : in  std_logic_vector (7  downto 0);
             rgb_o      : out std_logic_vector (7  downto 0);

             pos_y_o    : out std_logic_vector (10 downto 0)
         );

end computer;

architecture Structural of computer is

    constant pos_x  : std_logic_vector (10 downto 0) := "01000000000";
    signal pos_y    : std_logic_vector (10 downto 0);

begin

    pos_y_o <= pos_y;

    -- Instantiate control logic
    inst_computer_move : entity work.computer_move
    port map (
                 clk_vs_i   => clk_vs_i   ,
                 ball_x_i   => ball_x_i   ,
                 ball_y_i   => ball_y_i   ,
                 pos_y_o    => pos_y   
             );

    -- Instantiate display logic
    inst_computer_disp : entity work.computer_disp
    port map (
                 clk_i      => clk_i      ,
                 pos_x_i    => pos_x      ,
                 pos_y_i    => pos_y      ,
                 pixel_x_i  => pixel_x_i  ,
                 pixel_y_i  => pixel_y_i  ,
                 rgb_i      => rgb_i      ,
                 rgb_o      => rgb_o      
             );

end Structural;

