library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.sprite_pkg.ALL;

-- This displays a sprite

entity sprite is

    generic (
                PATTERN    : pattern_t; -- Bitmap image
                COLOR      : std_logic_vector(7 downto 0) := "11111111";
                SIMULATION : boolean := false;
                FREQ       : integer := 25000000 -- Input clock frequency
            );
    port (
             -- Position of sprite
             pos_x_i    : in  std_logic_vector (10 downto 0);
             pos_y_i    : in  std_logic_vector (10 downto 0);

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

    process (pixel_x_i, pixel_y_i, rgb_i, pos_x_i, pos_y_i)
        variable offset_x : integer range 0 to SIZE_X-1;
        variable offset_y : integer range 0 to SIZE_Y-1;
    begin
        rgb_o <= rgb_i; -- Default is transparent

        if pixel_x_i >= pos_x_i and pixel_x_i < pos_x_i + SIZE_X and
           pixel_y_i >= pos_y_i and pixel_y_i < pos_y_i + SIZE_Y then
            offset_x := conv_integer(pixel_x_i - pos_x_i);
            offset_y := conv_integer(pixel_y_i - pos_y_i);

            if PATTERN(offset_y)(offset_x) = '1' then
                rgb_o <= COLOR;
            end if;

        end if;

    end process;

end Structural;

