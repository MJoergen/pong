library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.sprite_pkg.all;

library work;
  use work.video_modes_pkg.all;

entity pong_mega65r6 is
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
    paddle_drain_o          : out   std_logic
  );
end entity pong_mega65r6;

architecture synthesis of pong_mega65r6 is

  constant C_VIDEO_MODE : video_modes_type := C_VIDEO_MODE_720_576_50;

  signal core_clk       : std_logic;
  signal core_rst       : std_logic;
  signal core_ce        : std_logic;
  signal core_bat_up    : std_logic;
  signal core_bat_down  : std_logic;
  signal core_sprites   : sprite_array_type;
  signal core_collision : std_logic_vector(0 to C_NUM_SPRITES - 1);

  signal vga_vs_d : std_logic;

begin

  mega65r6_inst : entity work.mega65r6
    generic map (
      G_VIDEO_MODE => C_VIDEO_MODE
    )
    port map (
      clk_i                   => clk_i,
      reset_button_i          => reset_button_i,
      vga_red_o               => vga_red_o,
      vga_green_o             => vga_green_o,
      vga_blue_o              => vga_blue_o,
      vga_hs_o                => vga_hs_o,
      vga_vs_o                => vga_vs_o,
      vga_scl_io              => vga_scl_io,
      vga_sda_io              => vga_sda_io,
      vdac_clk_o              => vdac_clk_o,
      vdac_sync_n_o           => vdac_sync_n_o,
      vdac_blank_n_o          => vdac_blank_n_o,
      vdac_psave_n_o          => vdac_psave_n_o,
      kb_io0_o                => kb_io0_o,
      kb_io1_o                => kb_io1_o,
      kb_io2_i                => kb_io2_i,
      kb_jtagen_o             => kb_jtagen_o,
      fa_up_n_i               => fa_up_n_i,
      fa_down_n_i             => fa_down_n_i,
      fa_left_n_i             => fa_left_n_i,
      fa_right_n_i            => fa_right_n_i,
      fa_fire_n_i             => fa_fire_n_i,
      fa_fire_n_o             => fa_fire_n_o,
      fa_up_n_o               => fa_up_n_o,
      fa_left_n_o             => fa_left_n_o,
      fa_down_n_o             => fa_down_n_o,
      fa_right_n_o            => fa_right_n_o,
      fb_up_n_i               => fb_up_n_i,
      fb_down_n_i             => fb_down_n_i,
      fb_left_n_i             => fb_left_n_i,
      fb_right_n_i            => fb_right_n_i,
      fb_fire_n_i             => fb_fire_n_i,
      fb_up_n_o               => fb_up_n_o,
      fb_down_n_o             => fb_down_n_o,
      fb_fire_n_o             => fb_fire_n_o,
      fb_right_n_o            => fb_right_n_o,
      fb_left_n_o             => fb_left_n_o,
      joystick_5v_disable_o   => joystick_5v_disable_o,
      joystick_5v_powergood_i => joystick_5v_powergood_i,
      paddle_i                => paddle_i,
      paddle_drain_o          => paddle_drain_o,
      -- Connect to Game Logic
      core_clk_o              => core_clk,
      core_rst_o              => core_rst,
      core_ce_o               => core_ce,
      core_bat_up_o           => core_bat_up,
      core_bat_down_o         => core_bat_down,
      core_sprites_i          => core_sprites,
      core_collision_o        => core_collision
    ); -- mega65r6_inst : entity work.mega65r6

  pong_inst : entity work.pong
    generic map (
      G_SCREEN_X => C_VIDEO_MODE.H_PIXELS,
      G_SCREEN_Y => C_VIDEO_MODE.V_PIXELS
    )
    port map (
      clk_i       => core_clk,
      rst_i       => core_rst,
      ce_i        => core_ce,
      btn_up_i    => core_bat_up,
      btn_down_i  => core_bat_down,
      sprites_o   => core_sprites,
      collision_i => core_collision
    ); -- pong_inst : entity work.pong

end architecture synthesis;

