library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.sprite_pkg.all;

entity sprite is
  port (
    clk_i       : in    std_logic;
    rst_i       : in    std_logic;
    vsync_i     : in    std_logic;

    -- Sprites
    sprites_i   : in    sprite_array_type;

    -- Display
    pixel_x_i   : in    natural range 0 to 2047;
    pixel_y_i   : in    natural range 0 to 2047;
    rgb_i       : in    std_logic_vector(23 downto 0);
    rgb_o       : out   std_logic_vector(23 downto 0);

    -- Collision detect
    collision_o : out   std_logic_vector(0 to C_NUM_SPRITES - 1)
  );
end entity sprite;

architecture synthesis of sprite is

  constant C_SIZE_X : natural                                      := 16;
  constant C_SIZE_Y : natural                                      := 16;

  signal   active_pixel : std_logic_vector(0 to C_NUM_SPRITES - 1) := (others => '0');
  signal   collision    : std_logic_vector(0 to C_NUM_SPRITES - 1) := (others => '0');

  signal   vsync_d : std_logic;

  pure function count_ones (
    arg : std_logic_vector
  ) return natural is
    variable res_v : natural := 0;
  begin
    for i in arg'range loop
      if arg(i) = '1' then
        res_v := res_v + 1;
      end if;
    end loop;
    return res_v;
  end function count_ones;

begin

  collision_o <= collision;

  pixel_proc : process (clk_i)
    variable offset_x_v : natural range 0 to C_SIZE_X - 1;
    variable offset_y_v : natural range 0 to C_SIZE_Y - 1;

    variable pos_x_v    : natural range 0 to 2047;
    variable pos_y_v    : natural range 0 to 2047;
    variable bitmap_v   : bitmap_type;
    variable color_v    : std_logic_vector(23 downto 0);
    variable active_v   : std_logic;

  begin
    if rising_edge(clk_i) then
      rgb_o        <= rgb_i;                                                              -- Default is transparent

      active_pixel <= (others => '0');                                                    -- No collisions.
      for i in 0 to C_NUM_SPRITES - 1 loop                                                -- Loop through each sprite
        pos_x_v  := sprites_i(i).pos_x;
        pos_y_v  := sprites_i(i).pos_y;
        bitmap_v := sprites_i(i).bitmap;
        color_v  := sprites_i(i).color;
        active_v := sprites_i(i).active;

        if active_v = '1' then
          if pixel_x_i >= pos_x_v and pixel_x_i < pos_x_v + C_SIZE_X and
             pixel_y_i >= pos_y_v and pixel_y_i < pos_y_v + C_SIZE_Y then
            offset_x_v := pixel_x_i - pos_x_v;
            offset_y_v := pixel_y_i - pos_y_v;

            if bitmap_v(offset_y_v)(offset_x_v) = '1' then
              rgb_o           <= color_v;
              active_pixel(i) <= '1';
            end if;
          end if;
        end if;
      end loop;

    end if;
  end process pixel_proc;

  collision_proc : process (clk_i)
    variable number_v : integer range 0 to 8;
  begin
    if rising_edge(clk_i) then
      vsync_d <= vsync_i;

      if vsync_d = '0' and vsync_i = '1' then
        collision <= (others => '0');
      end if;

      number_v := count_ones(active_pixel);

      if number_v > 1 then
        collision <= collision or active_pixel;
      end if;

      if rst_i = '1' then
        collision <= (others => '0');
      end if;
    end if;
  end process collision_proc;

end architecture synthesis;

