library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- This controls the ball

entity ball is

    generic (
                SIMULATION : boolean := false;
                FREQ       : integer := 25000000 -- Input clock frequency
            );
    port (
             -- Clock
             clk_i        : in  std_logic;  -- 25 MHz
             clk_vs_i     : in  std_logic;  -- 60 Hz

             -- Input control
             player_y_i   : in  std_logic_vector (10 downto 0);
             computer_y_i : in  std_logic_vector (10 downto 0);

             -- Display
             pixel_x_i    : in  std_logic_vector (10 downto 0);
             pixel_y_i    : in  std_logic_vector (10 downto 0);
             rgb_i        : in  std_logic_vector (7  downto 0);
             rgb_o        : out std_logic_vector (7  downto 0);

             -- Position
             pos_x_o      : out std_logic_vector (10 downto 0);
             pos_y_o      : out std_logic_vector (10 downto 0)
         );

end ball;

architecture Structural of ball is

    signal pos_x : std_logic_vector (10 downto 0);
    signal pos_y : std_logic_vector (10 downto 0);

begin

    pos_x_o <= pos_x;
    pos_y_o <= pos_y;

    -- Instantiate DUT
    inst_ball_move : entity work.ball_move
    port map (
                 clk_vs_i     => clk_vs_i     ,
                 player_y_i   => player_y_i   ,
                 computer_y_i => computer_y_i ,
                 pos_x_o      => pos_x        ,
                 pos_y_o      => pos_y    
             );

    -- Instantiate DUT
    inst_ball_disp : entity work.ball_disp
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

