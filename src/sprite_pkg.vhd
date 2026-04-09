library ieee;
  use ieee.std_logic_1164.all;

package sprite_pkg is

  type     bitmap_type is array (integer range 0 to 15) of std_logic_vector(15 downto 0);

  type     sprite_type is record
    pos_x  : natural range 0 to 2047;
    pos_y  : natural range 0 to 2047;
    bitmap : bitmap_type;
    color  : std_logic_vector(23 downto 0);
    active : std_logic;
  end record sprite_type;

  constant C_COLOR_BLACK      : std_logic_vector(23 downto 0) := X"000000";
  constant C_COLOR_RED        : std_logic_vector(23 downto 0) := X"FF0000";
  constant C_COLOR_GREEN      : std_logic_vector(23 downto 0) := X"00FF00";
  constant C_COLOR_BLUE       : std_logic_vector(23 downto 0) := X"0000FF";
  constant C_COLOR_WHITE      : std_logic_vector(23 downto 0) := X"FFFFFF";
  constant C_COLOR_YELLOW     : std_logic_vector(23 downto 0) := X"FFFF00";
  constant C_COLOR_CYAN       : std_logic_vector(23 downto 0) := X"00FFFF";
  constant C_COLOR_MAGENTA    : std_logic_vector(23 downto 0) := X"FF00FF";
  constant C_COLOR_DARK_GREY  : std_logic_vector(23 downto 0) := X"555555";
  constant C_COLOR_LIGHT_GREY : std_logic_vector(23 downto 0) := X"AAAAAA";

  constant C_BITMAP_OFF : bitmap_type := (others => (others => '0'));
  constant C_BITMAP_ON  : bitmap_type := (others => (others => '1'));

  constant C_NOSPRITE : sprite_type := (
                                         pos_x  => 0,
                                         pos_y  => 0,
                                         bitmap => C_BITMAP_OFF,
                                         color  => C_COLOR_BLACK,
                                         active => '0');

  type     sprite_array_type is array (0 to 7) of sprite_type;

end package sprite_pkg;

