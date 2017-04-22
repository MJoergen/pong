library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

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

    signal rgb_from_background : std_logic_vector (7 downto 0);
    signal rgb_from_player     : std_logic_vector (7 downto 0);

    signal player_pos_y : std_logic_vector (10 downto 0);

    signal vga_hs : std_logic;
    signal vga_vs : std_logic;

begin

    rgb_from_background <= "01010101" when blank = '0' else "00000000";

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
    inst_player : entity work.player
    generic map (
                    SIMULATION => SIMULATION
                )
    port map (
             clk_i      => clk_i    ,
             clk_vs_i   => vga_vs   ,
             btn_up_i   => btn_i(3) ,
             btn_down_i => btn_i(0) ,
             pixel_x_i  => pixel_x  ,
             pixel_y_i  => pixel_y  ,
             rgb_i      => rgb_from_background ,
             rgb_o      => rgb_from_player     ,
             pos_y_o    => player_pos_y    
             );

    vga_col_o <= rgb_from_player;

end Structural;

