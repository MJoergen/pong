library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.ram74ls189_datatypes.all;
use work.vga_bitmap_pkg.ALL;

-- This controls the player

entity player is

    generic (
                SIMULATION : boolean := false;
                FREQ       : integer := 25000000 -- Input clock frequency
            );
    port (
             -- Clock
             clk_i      : in  std_logic;  -- 25 MHz

             -- Input switches, buttons, and PMOD's
             btn_up_i   : in  std_logic;
             btb_down_i : in  std_logic;

             -- Display
             rgb_i      : in  std_logic_vector (7 downto 0);
             rgb_o      : out std_logic_vector (7 downto 0);
             pixel_x_i  : in  std_logic_vector (9 downto 0);
             pixel_y_i  : in  std_logic_vector (9 downto 0);

             -- Position
             pos_y_o    : out std_logic_vector (9 downto 0)
         );

end player;

architecture Structural of player is

    constant pos_x  : std_logic_vector (9 downto 0) := "0000000000";
    signal pos_y    : std_logic_vector (9 downto 0) := "0100000000";

    constant size_x : std_logic_vector (9 downto 0) := "0000000111";
    constant size_y : std_logic_vector (9 downto 0) := "0000111111";

begin

    pos_y_o <= pos_y;

    process (clk_i)
    begin
        if rising_edge(clk_i) then
            if btn_up_i = '1' then
                pos_y <= pos_y - 1;
            elsif btn_down_i = '1' then
                pos_y <= pos_y + 1;
            end if;
        end if;
    end process;

    process (pixel_x_i, pixel_y_i)
        variable offset_x : std_logic_vector(9 downto 0);
        variable offset_y : std_logic_vector(9 downto 0);
    begin
        rgb_o <= rgb_i;

        if pixel_x_i >= pos_x and pixel_x_i < pos_x + size_x and
           pixel_y_i >= pos_y and pixel_y_i < pos_y + size_y then
            offset_x := pixel_x_i - pos_x;
            offset_y := pixel_y_i - pos_y;

            rgo_o <= bitmap(offset_x, offset_y);
        end if;

    end process;

end Structural;

