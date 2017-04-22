library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- This displays the player

entity player_disp is

    generic (
                SIMULATION : boolean := false;
                FREQ       : integer := 25000000 -- Input clock frequency
            );
    port (
             -- Clock
             clk_i      : in  std_logic;  -- 25 MHz

             -- Position
             pos_x_i    : in  std_logic_vector (10 downto 0);
             pos_y_i    : in  std_logic_vector (10 downto 0);

             -- Display
             pixel_x_i  : in  std_logic_vector (10 downto 0);
             pixel_y_i  : in  std_logic_vector (10 downto 0);
             rgb_i      : in  std_logic_vector (7  downto 0);
             rgb_o      : out std_logic_vector (7  downto 0)
         );

end player_disp;

architecture Structural of player_disp is

    constant size_x : std_logic_vector (10 downto 0) := "00000000111";
    constant size_y : std_logic_vector (10 downto 0) := "00000111111";

    -- Divide by CHAR_WIDTH
    type color_t is array (0 to 1) of std_logic_vector (7 downto 0);
    constant color : color_t := (
        "00000000",    -- Pixel off -> black
        "11111111" );  -- Pixel on  -> white

    type bitmap_t is array (0 to conv_integer(size_y)-1) of
        std_logic_vector (conv_integer(size_x)-1 downto 0);
    constant bitmap : bitmap_t := (others => (others => '1'));

begin

    process (pixel_x_i, pixel_y_i)
        variable offset_x : integer range 0 to 799;
        variable offset_y : integer range 0 to 524;
        variable pixel    : integer range 0 to 1;
    begin
        rgb_o <= rgb_i;

        if pixel_x_i >= pos_x_i and pixel_x_i < pos_x_i + size_x and
           pixel_y_i >= pos_y_i and pixel_y_i < pos_y_i + size_y then
            offset_x := conv_integer(pixel_x_i - pos_x_i);
            offset_y := conv_integer(pixel_y_i - pos_y_i);

            if bitmap(offset_y)(offset_x) = '1' then
                pixel := 1;
            else
                pixel := 0;
            end if;
            rgb_o <= color(pixel);
        end if;

    end process;

end Structural;

