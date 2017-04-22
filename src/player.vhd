library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- This controls the player

entity player is

    generic (
                SIMULATION : boolean := false;
                FREQ       : integer := 25000000 -- Input clock frequency
            );
    port (
             -- Clock
             clk_i      : in  std_logic;  -- 25 MHz
             clk_vs_i   : in  std_logic;  -- 60 Hz

             -- Input control
             btn_up_i   : in  std_logic;
             btn_down_i : in  std_logic;

             -- Display
             pixel_x_i  : in  std_logic_vector (10 downto 0);
             pixel_y_i  : in  std_logic_vector (10 downto 0);
             rgb_i      : in  std_logic_vector (7  downto 0);
             rgb_o      : out std_logic_vector (7  downto 0);

             -- Position
             pos_y_o    : out std_logic_vector (10 downto 0)
         );

end player;

architecture Structural of player is

    constant pos_x  : std_logic_vector (10 downto 0) := "00000000000";
    signal pos_y    : std_logic_vector (10 downto 0) := "00100000000";

begin

    pos_y_o <= pos_y;

    -- Instantiate DUT
    inst_player_move : entity work.player_move
    port map (
                 clk_vs_i   => clk_vs_i   ,
                 btn_up_i   => btn_up_i   ,
                 btn_down_i => btn_down_i ,
                 pos_y_o    => pos_y    
             );

    -- Instantiate DUT
    inst_ball_sprite : entity work.sprite
    generic map (
                COLOR   => "11111111",
                PATTERN => (others => "111111111000000000000000")
                )
    port map (
                 pos_x_i    => pos_x      ,
                 pos_y_i    => pos_y      ,
                 pixel_x_i  => pixel_x_i  ,
                 pixel_y_i  => pixel_y_i  ,
                 rgb_i      => rgb_i      ,
                 rgb_o      => rgb_o      
             );

end Structural;

