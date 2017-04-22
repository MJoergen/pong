library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.sprite_pkg.ALL;

-- This displays a sprite

entity sprite is

    generic (
                SIMULATION : boolean := false;
                FREQ       : integer := 25000000 -- Input clock frequency
            );
    port (
             -- Sprites
             sprites_i  : in  sprite_array_t;

             -- Display
             pixel_x_i  : in  std_logic_vector (10 downto 0);
             pixel_y_i  : in  std_logic_vector (10 downto 0);
             rgb_i      : in  std_logic_vector (7  downto 0);
             rgb_o      : out std_logic_vector (7  downto 0)
         );

end sprite;

architecture Structural of sprite is

    constant SIZE_X : integer := 24;
    constant SIZE_Y : integer := 21;

begin

    process (pixel_x_i, pixel_y_i, rgb_i, sprites_i)
        variable offset_x : integer range 0 to SIZE_X-1;
        variable offset_y : integer range 0 to SIZE_Y-1;

        variable pos_x    : std_logic_vector (10 downto 0);
        variable pos_y    : std_logic_vector (10 downto 0);
        variable pattern  : pattern_t;
        variable color    : std_logic_vector (7 downto 0);
        variable active   : std_logic;

    begin
        rgb_o <= rgb_i; -- Default is transparent

        for i in 0 to 7 loop -- Loop through each sprite
            pos_x   := sprites_i(i).pos_x;
            pos_y   := sprites_i(i).pos_y;
            pattern := sprites_i(i).pattern;
            color   := sprites_i(i).color;
            active  := sprites_i(i).active;
            
            if active = '1' then
                if pixel_x_i >= pos_x and pixel_x_i < pos_x + SIZE_X and
                pixel_y_i >= pos_y and pixel_y_i < pos_y + SIZE_Y then
                    offset_x := conv_integer(pixel_x_i - pos_x);
                    offset_y := conv_integer(pixel_y_i - pos_y);

                    if pattern(offset_y)(offset_x) = '1' then
                        rgb_o <= color;
                    end if;

                end if;
            end if;
        end loop;

    end process;

end Structural;

