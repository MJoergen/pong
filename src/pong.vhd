library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.sprite_pkg.ALL;

-- This is the top level
-- See diagram here: https://github.com/MJoergen/bcomp2/blob/master/img/Block_diagram_new.png

entity pong is

    generic (
                SIMULATION : boolean := false;
                FREQ       : integer := 25000000 -- Input clock frequency
            );
    port (
             -- Clock
             clk_i     : in  std_logic;  -- 25 MHz

             -- Input switches, buttons, and PMOD's
             sw_i      : in  std_logic_vector (7 downto 0);
             btn_i     : in  std_logic_vector (3 downto 0);

             -- Output LEDs
--             led_o     : out std_logic_vector (7 downto 0)

             -- Output 7-segment display
--             seg_ca_o  : out std_logic_vector (6 downto 0);
--             seg_dp_o  : out std_logic;
--             seg_an_o  : out std_logic_vector (3 downto 0);

             -- Output to VGA monitor
             vga_hs_o  : out std_logic;
             vga_vs_o  : out std_logic;
             vga_col_o : out std_logic_vector(7 downto 0)
         );

end pong;

architecture Structural of pong is

    signal pixel_x : std_logic_vector (10 downto 0);
    signal pixel_y : std_logic_vector (10 downto 0);
    signal blank   : std_logic;

    signal vga_col : std_logic_vector (7 downto 0);

    signal player_y   : std_logic_vector (10 downto 0);
    signal computer_y : std_logic_vector (10 downto 0);
    signal ball_x     : std_logic_vector (10 downto 0);
    signal ball_y     : std_logic_vector (10 downto 0);

    signal vga_hs : std_logic;
    signal vga_vs : std_logic;

    signal sprites : sprite_array_t := (others => NOSPRITE);
    signal collision : std_logic_vector (0 to 7);

    constant player_bitmap : pattern_t := (
        others => "111111100000000000000000");
    constant ball_bitmap : pattern_t := (
             0 => "001110000000000000000000",
             1 => "011111000000000000000000",
             2 => "111111100000000000000000",
             3 => "111111100000000000000000",
             4 => "111111100000000000000000",
             5 => "011111000000000000000000",
             6 => "001110000000000000000000",
        others => "000000000000000000000000");

begin

    sprites(0).pos_x   <= "00000000000";
    sprites(0).pos_y   <= player_y;
    sprites(0).pattern <= player_bitmap;
    sprites(0).color   <= "11111111";
    sprites(0).active  <= '1';

    sprites(1).pos_x   <= "01000000000";
    sprites(1).pos_y   <= computer_y;
    sprites(1).pattern <= player_bitmap;
    sprites(1).color   <= "00000000";
    sprites(1).active  <= '1';

    sprites(2).pos_x   <= ball_x;
    sprites(2).pos_y   <= ball_y;
    sprites(2).pattern <= ball_bitmap;
    sprites(2).color   <= "11100000";
    sprites(2).active  <= '1';

    sprites(3).active  <= '0';
    sprites(4).active  <= '0';
    sprites(5).active  <= '0';
    sprites(6).active  <= '0';
    sprites(7).active  <= '0';

    vga_hs_o <= vga_hs;
    vga_vs_o <= vga_vs;

    -- Instantiate VGA controller
    inst_vga_controller_640_60 : entity work.vga_controller_640_60
    port map (
                 rst_i     => '0'      , -- Not used.
                 vga_clk_i => clk_i    , -- 25 MHz crystal clock
                 HS_o      => vga_hs   ,
                 VS_o      => vga_vs   ,
                 hcount_o  => pixel_x  ,
                 vcount_o  => pixel_y  ,
                 blank_o   => blank
             );

    -- Instantiate Player
    inst_player : entity work.player_move
    port map (
                 clk_vs_i   => vga_vs   ,
                 btn_up_i   => btn_i(3) ,
                 btn_down_i => btn_i(0) ,
                 pos_y_o    => player_y    
             );

    -- Instantiate Computer
    inst_computer_move : entity work.computer_move
    port map (
                 clk_vs_i   => vga_vs     ,
                 ball_x_i   => ball_x     ,
                 ball_y_i   => ball_y     ,
                 pos_y_o    => computer_y   
             );

    -- Instantiate Ball
    inst_ball_move : entity work.ball_move
    port map (
                 clk_vs_i     => vga_vs     ,
                 player_y_i   => player_y   ,
                 computer_y_i => computer_y ,
                 pos_x_o      => ball_x     ,
                 pos_y_o      => ball_y    
             );

    inst_sprites : entity work.sprite
    port map (
                 sprites_i   => sprites    ,
                 pixel_x_i   => pixel_x    ,
                 pixel_y_i   => pixel_y    ,
                 rgb_i       => "01010101" , -- Background color
                 rgb_o       => vga_col    ,
                 collision_o => collision
             );

    vga_col_o <= vga_col when blank = '0' else "00000000";

end Structural;

