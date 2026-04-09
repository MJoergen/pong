library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.sprite_pkg.all;

library work;
  use work.video_modes_pkg.all;

entity vga_wrapper is
  generic (
    G_VIDEO_MODE : video_modes_type
  );
  port (
    vga_clk_i       : in    std_logic;
    vga_rst_i       : in    std_logic;
    vga_sprites_i   : in    sprite_array_type;
    vga_collision_o : out   std_logic_vector(0 to 7);

    vga_red_o       : out   std_logic_vector(7 downto 0);
    vga_green_o     : out   std_logic_vector(7 downto 0);
    vga_blue_o      : out   std_logic_vector(7 downto 0);
    vga_hs_o        : out   std_logic;
    vga_vs_o        : out   std_logic;
    vga_scl_io      : inout std_logic;
    vga_sda_io      : inout std_logic;
    vdac_clk_o      : out   std_logic;
    vdac_sync_n_o   : out   std_logic;
    vdac_blank_n_o  : out   std_logic;
    vdac_psave_n_o  : out   std_logic
  );
end entity vga_wrapper;

architecture synthesis of vga_wrapper is

  signal vga_vs      : std_logic;
  signal vga_vs_d    : std_logic;
  signal vga_hs      : std_logic;
  signal vga_de      : std_logic;
  signal vga_pixel_x : std_logic_vector(G_VIDEO_MODE.PIX_SIZE - 1 downto 0);
  signal vga_pixel_y : std_logic_vector(G_VIDEO_MODE.PIX_SIZE - 1 downto 0);

  signal vga_col : std_logic_vector(23 downto 0);

begin

  -- Instantiate VGA driver
  video_sync_inst : entity work.video_sync
    generic map (
      G_VIDEO_MODE => G_VIDEO_MODE
    )
    port map (
      clk_i     => vga_clk_i,
      rst_i     => vga_rst_i,
      vs_o      => vga_vs,
      hs_o      => vga_hs,
      de_o      => vga_de,
      pixel_x_o => vga_pixel_x,
      pixel_y_o => vga_pixel_y
    ); -- video_sync_inst : entity work.video_sync

  -- Display sprites
  sprite_inst : entity work.sprite
    port map (
      clk_i       => vga_clk_i,
      rst_i       => vga_rst_i,
      vsync_i     => vga_vs,
      sprites_i   => vga_sprites_i,
      pixel_x_i   => to_integer(unsigned(vga_pixel_x)),
      pixel_y_i   => to_integer(unsigned(vga_pixel_y)),
      rgb_i       => C_COLOR_DARK_GREY, -- Background color
      rgb_o       => vga_col,
      collision_o => vga_collision_o
    ); -- sprite_inst : entity work.sprite


  vga_vs_o       <= vga_vs;
  vga_hs_o       <= vga_hs;
  vga_red_o      <= vga_col(23 downto 16) when vga_de = '1' else
                    X"00";
  vga_green_o    <= vga_col(15 downto 8) when vga_de = '1' else
                    X"00";
  vga_blue_o     <= vga_col(7 downto 0) when vga_de = '1' else
                    X"00";

  -- TBD
  vga_scl_io     <= 'Z';
  vga_sda_io     <= 'Z';
  vdac_clk_o     <= vga_clk_i;
  vdac_sync_n_o  <= '0';
  vdac_blank_n_o <= '1';
  vdac_psave_n_o <= '1';

end architecture synthesis;

