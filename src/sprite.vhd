library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use work.sprite_pkg.all;

-- This displays a sprite

entity sprite is
  generic (
    SIMULATION : boolean := false;
    FREQ       : integer := 25000000 -- Input clock frequency
  );
  port (
    clk_i       : in    std_logic;
    vga_vs_i    : in    std_logic;

    -- Sprites
    sprites_i   : in    sprite_array_t;

    -- Display
    pixel_x_i   : in    std_logic_vector(10 downto 0);
    pixel_y_i   : in    std_logic_vector(10 downto 0);
    rgb_i       : in    std_logic_vector(7  downto 0);
    rgb_o       : out   std_logic_vector(7  downto 0);

    -- Collision detect
    collision_o : out   std_logic_vector(0 to 7)
  );
end entity sprite;

architecture structural of sprite is

  constant C_SIZE_X : integer                      := 24;
  constant C_SIZE_Y : integer                      := 21;

  signal   active_pixel : std_logic_vector(0 to 7) := "00000000";
  signal   collision    : std_logic_vector(0 to 7) := "00000000";
  signal   vga_vs_reg   : std_logic;

begin

  collision_o <= collision;

  pixel_proc : process (clk_i)
    variable offset_x_v : integer range 0 to C_SIZE_X - 1;
    variable offset_y_v : integer range 0 to C_SIZE_Y - 1;

    variable pos_x_v    : std_logic_vector(10 downto 0);
    variable pos_y_v    : std_logic_vector(10 downto 0);
    variable pattern_v  : pattern_t;
    variable color_v    : std_logic_vector(7 downto 0);
    variable active_v   : std_logic;

  begin
    if rising_edge(clk_i) then
      rgb_o        <= rgb_i;                                              -- Default is transparent

      active_pixel <= "00000000";                                         -- No collisions.
      for i in 0 to 7 loop                                                -- Loop through each sprite
        pos_x_v   := sprites_i(i).pos_x;
        pos_y_v   := sprites_i(i).pos_y;
        pattern_v := sprites_i(i).pattern;
        color_v   := sprites_i(i).color;
        active_v  := sprites_i(i).active;

        if active_v = '1' then
          if pixel_x_i >= pos_x_v and pixel_x_i < pos_x_v + C_SIZE_X and
             pixel_y_i >= pos_y_v and pixel_y_i < pos_y_v + C_SIZE_Y then
            offset_x_v := conv_integer(pixel_x_i - pos_x_v);
            offset_y_v := conv_integer(pixel_y_i - pos_y_v);

            if pattern(offset_y_v)(offset_x_v) = '1' then
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
      vga_vs_reg <= vga_vs_i;

      if vga_vs_i = '1' and vga_vs_reg = '0' then
        collision <= "00000000";
      end if;

      number_v := conv_integer(active_pixel(0 to 0)) +
                  conv_integer(active_pixel(1 to 1)) +
                  conv_integer(active_pixel(2 to 2)) +
                  conv_integer(active_pixel(3 to 3)) +
                  conv_integer(active_pixel(4 to 4)) +
                  conv_integer(active_pixel(5 to 5)) +
                  conv_integer(active_pixel(6 to 6)) +
                  conv_integer(active_pixel(7 to 7));

      if number_v > 1 then
        collision <= collision or active_pixel;
      end if;
    end if;
  end process collision_proc;

end architecture structural;

