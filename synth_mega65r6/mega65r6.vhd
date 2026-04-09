library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.sprite_pkg.all;

entity mega65r6 is
  port (
    -- Onboard crystal oscillator = 100 MHz
    clk_i                   : in    std_logic;

    -- Reset button on the side of the machine
    reset_button_i          : in    std_logic; -- Active high

    -- VGA via VDAC. U3 = ADV7125BCPZ170
    vga_red_o               : out   std_logic_vector(7 downto 0);
    vga_green_o             : out   std_logic_vector(7 downto 0);
    vga_blue_o              : out   std_logic_vector(7 downto 0);
    vga_hs_o                : out   std_logic;
    vga_vs_o                : out   std_logic;
    vga_scl_io              : inout std_logic;
    vga_sda_io              : inout std_logic;
    vdac_clk_o              : out   std_logic;
    vdac_sync_n_o           : out   std_logic;
    vdac_blank_n_o          : out   std_logic;
    vdac_psave_n_o          : out   std_logic;

    -- MEGA65 smart keyboard controller
    kb_io0_o                : out   std_logic; -- clock to keyboard
    kb_io1_o                : out   std_logic; -- data output to keyboard
    kb_io2_i                : in    std_logic; -- data input from keyboard
    kb_jtagen_o             : out   std_logic;

    -- Joysticks and Paddles
    fa_up_n_i               : in    std_logic;
    fa_down_n_i             : in    std_logic;
    fa_left_n_i             : in    std_logic;
    fa_right_n_i            : in    std_logic;
    fa_fire_n_i             : in    std_logic;
    fa_fire_n_o             : out   std_logic; -- 0: Drive pin low (output). 1: Leave pin floating (input)
    fa_up_n_o               : out   std_logic;
    fa_left_n_o             : out   std_logic;
    fa_down_n_o             : out   std_logic;
    fa_right_n_o            : out   std_logic;
    fb_up_n_i               : in    std_logic;
    fb_down_n_i             : in    std_logic;
    fb_left_n_i             : in    std_logic;
    fb_right_n_i            : in    std_logic;
    fb_fire_n_i             : in    std_logic;
    fb_up_n_o               : out   std_logic;
    fb_down_n_o             : out   std_logic;
    fb_fire_n_o             : out   std_logic;
    fb_right_n_o            : out   std_logic;
    fb_left_n_o             : out   std_logic;

    -- Joystick power supply
    joystick_5v_disable_o   : out   std_logic; -- 1: Disable 5V power supply to joysticks
    joystick_5v_powergood_i : in    std_logic;

    paddle_i                : in    std_logic_vector(3 downto 0);
    paddle_drain_o          : out   std_logic;

    -- Connect to Core
    core_clk_o              : out   std_logic;
    core_rst_o              : out   std_logic;
    core_bat_up_o           : out   std_logic;
    core_bat_down_o         : out   std_logic;
    core_sprites_i          : in    sprite_array_type;
    core_collision_o        : out   std_logic_vector(0 to 7)
  );
end entity mega65r6;

architecture synthesis of mega65r6 is

  signal vga_clk : std_logic;
  signal vga_rst : std_logic;

  signal pixel_x : natural range 0 to 2047;
  signal pixel_y : natural range 0 to 2047;
  signal blank   : std_logic;
  signal vga_hs  : std_logic;
  signal vga_vs  : std_logic;
  signal vga_col : std_logic_vector(23 downto 0);

begin

  -- Generate local clock and reset
  clk_rst_inst : entity work.clk_rst
    port map (
      clk_i     => clk_i,
      rst_i     => reset_button_i,
      vga_clk_o => vga_clk,
      vga_rst_o => vga_rst
    ); -- clk_rst_inst : entity work.clk_rst

  -- Let the core run at the VGA clock. This avoids any Clock Domain Crossings
  core_clk_o            <= vga_clk;
  core_rst_o            <= vga_rst;

  -- TBD: Add keyboard controller
  core_bat_up_o         <= '0';
  core_bat_down_o       <= '0';

  -- Instantiate VGA controller
  vga_controller_640_60_inst : entity work.vga_controller_640_60
    port map (
      vga_clk_i => vga_clk,
      vga_rst_i => vga_rst,
      hs_o      => vga_hs,
      vs_o      => vga_vs,
      hcount_o  => pixel_x,
      vcount_o  => pixel_y,
      blank_o   => blank
    ); -- vga_controller_640_60_inst : entity work.vga_controller_640_60

  -- Display sprites
  sprite_inst : entity work.sprite
    port map (
      clk_i       => vga_clk,
      rst_i       => vga_rst,
      vsync_i     => vga_vs,
      sprites_i   => core_sprites_i,
      pixel_x_i   => pixel_x,
      pixel_y_i   => pixel_y,
      rgb_i       => C_COLOR_DARK_GREY, -- Background color
      rgb_o       => vga_col,
      collision_o => core_collision_o
    ); -- sprite_inst : entity work.sprite

  vga_red_o             <= vga_col(23 downto 16) when blank = '0' else
                           X"00";
  vga_green_o           <= vga_col(15 downto 8) when blank = '0' else
                           X"00";
  vga_blue_o            <= vga_col(7 downto 0) when blank = '0' else
                           X"00";
  vga_hs_o              <= vga_hs;
  vga_vs_o              <= vga_vs;

  -- TBD
  vga_scl_io            <= 'Z';
  vga_sda_io            <= 'Z';
  vdac_clk_o            <= '0';
  vdac_sync_n_o         <= '0';
  vdac_blank_n_o        <= '1';
  vdac_psave_n_o        <= '1';

  -- MEGA65 smart keyboard controller
  kb_io0_o              <= '0';
  kb_io1_o              <= '0';
  kb_jtagen_o           <= '0';

  -- Joysticks and Paddles
  fa_fire_n_o           <= '1';
  fa_up_n_o             <= '1';
  fa_left_n_o           <= '1';
  fa_down_n_o           <= '1';
  fa_right_n_o          <= '1';
  fb_up_n_o             <= '1';
  fb_down_n_o           <= '1';
  fb_fire_n_o           <= '1';
  fb_right_n_o          <= '1';
  fb_left_n_o           <= '1';

  -- Joystick power supply
  joystick_5v_disable_o <= '0';

  paddle_drain_o        <= '0';

end architecture synthesis;

