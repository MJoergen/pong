library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- This controls the player

entity player is

    generic (
                SIMULATION : boolean := false;
                FREQ       : integer := 25000000 -- Input clock frequency
            );
    port (
             -- Clock
             clk_i      : in  std_logic;  -- 25 MHz
             clk_vs_i   : in  std_logic;  -- 60 Hz

             -- Input control
             btn_up_i   : in  std_logic;
             btn_down_i : in  std_logic;

             -- Display
             pixel_x_i  : in  std_logic_vector (10 downto 0);
             pixel_y_i  : in  std_logic_vector (10 downto 0);
             rgb_i      : in  std_logic_vector (7  downto 0);
             rgb_o      : out std_logic_vector (7  downto 0);

             -- Position
             pos_y_o    : out std_logic_vector (10 downto 0)
         );

end player;

architecture Structural of player is

    constant pos_x  : std_logic_vector (10 downto 0) := "00000000000";
    signal pos_y    : std_logic_vector (10 downto 0) := "00100000000";

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

    pos_y_o <= pos_y;

    process (clk_vs_i)
    begin
        if rising_edge(clk_vs_i) then
            if btn_up_i = '1' and pos_y /= "00000000000" then
                pos_y <= pos_y - 1;
            elsif btn_down_i = '1' and pos_y /= "00110000000" then
                pos_y <= pos_y + 1;
            end if;
        end if;
    end process;


    process (pixel_x_i, pixel_y_i)
        variable offset_x : integer range 0 to 799;
        variable offset_y : integer range 0 to 524;
        variable pixel    : integer range 0 to 1;
    begin
        rgb_o <= rgb_i;

        if pixel_x_i >= pos_x and pixel_x_i < pos_x + size_x and
           pixel_y_i >= pos_y and pixel_y_i < pos_y + size_y then
            offset_x := conv_integer(pixel_x_i - pos_x);
            offset_y := conv_integer(pixel_y_i - pos_y);

            if bitmap(offset_y)(offset_x) = '1' then
                pixel := 1;
            else
                pixel := 0;
            end if;
            rgb_o <= color(pixel);
        end if;

    end process;

end Structural;

