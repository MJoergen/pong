library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.sprite_pkg.all;

library work;
  use work.video_modes_pkg.all;

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
    core_ce_o               : out   std_logic;
    core_bat_up_o           : out   std_logic;
    core_bat_down_o         : out   std_logic;
    core_sprites_i          : in    sprite_array_type;
    core_collision_o        : out   std_logic_vector(0 to 7)
  );
end entity mega65r6;

architecture synthesis of mega65r6 is

  constant C_VIDEO_MODE : video_modes_type := C_VIDEO_MODE_800_600_60;

  signal   vga_clk  : std_logic;
  signal   vga_rst  : std_logic;
  signal   vga_vs_d : std_logic;

  -- Not used yet
  signal   matrix_ram_offset : integer range 0 to 15;
  signal   matrix_dia        : std_logic_vector(7 downto 0);
  signal   keyram_wea        : std_logic_vector(7 downto 0);

begin

  -- Generate local clock and reset
  clk_rst_inst : entity work.clk_rst
    port map (
      clk_i     => clk_i,
      rst_i     => reset_button_i,
      vga_clk_o => vga_clk,
      vga_rst_o => vga_rst
    ); -- clk_rst_inst : entity work.clk_rst

  -- Let the core run at the VGA clock. This avoids Clock Domain Crossings
  core_clk_o <= vga_clk;
  core_rst_o <= vga_rst;

  core_ce_proc : process (vga_clk)
  begin
    if rising_edge(vga_clk) then
      vga_vs_d  <= vga_vs_o;

      core_ce_o <= vga_vs_o and not vga_vs_d;
    end if;
  end process core_ce_proc;


  -- Instantiate keyboard controller
  mega65kbd_to_matrix_inst : entity work.mega65kbd_to_matrix
    generic map (
      G_CLOCK_KHZ => C_VIDEO_MODE.CLK_KHZ
    )
    port map (
      clk_i               => vga_clk,
      rst_i               => vga_rst,
      kio8_o              => kb_io0_o,
      kio9_o              => kb_io1_o,
      kio10_i             => kb_io2_i,
      powerled_steady_i   => '1',
      powerled_col_i      => X"CC8844",
      driveled_steady_i   => '1',
      driveled_blinking_i => '0',
      driveled_col_i      => X"4488CC",
      matrix_ram_offset_o => matrix_ram_offset,
      matrix_dia_o        => matrix_dia,
      keyram_wea_o        => keyram_wea,
      delete_o            => open,
      return_o            => open,
      fastkey_o           => open,
      restore_n_o         => open,
      capslock_n_o        => open,
      leftkey_o           => core_bat_up_o,
      upkey_o             => core_bat_down_o
    ); -- mega65kbd_to_matrix_inst : entity work.mega65kbd_to_matrix

  vga_wrapper_inst : entity work.vga_wrapper
    generic map (
      G_VIDEO_MODE => C_VIDEO_MODE
    )
    port map (
      vga_clk_i       => vga_clk,
      vga_rst_i       => vga_rst,
      vga_sprites_i   => core_sprites_i,
      vga_collision_o => core_collision_o,
      vga_red_o       => vga_red_o,
      vga_green_o     => vga_green_o,
      vga_blue_o      => vga_blue_o,
      vga_hs_o        => vga_hs_o,
      vga_vs_o        => vga_vs_o,
      vga_scl_io      => vga_scl_io,
      vga_sda_io      => vga_sda_io,
      vdac_clk_o      => vdac_clk_o,
      vdac_sync_n_o   => vdac_sync_n_o,
      vdac_blank_n_o  => vdac_blank_n_o,
      vdac_psave_n_o  => vdac_psave_n_o
    ); -- vga_wrapper_inst : entity work.vga_wrapper


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

  kb_jtagen_o           <= '0';

end architecture synthesis;

