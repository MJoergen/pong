library ieee;
  use ieee.std_logic_1164.all;

package sprite_pkg is

  type     pattern_type is array (integer range 0 to 20) of std_logic_vector(0 to 23);

  type     sprite_type is record
    pos_x   : std_logic_vector(10 downto 0);
    pos_y   : std_logic_vector(10 downto 0);
    pattern : pattern_type;
    color   : std_logic_vector(7 downto 0);
    active  : std_logic;
  end record sprite_type;

  constant C_NOSPRITE : sprite_type := (
                                         pos_x   => "00000000000",
                                         pos_y   => "00000000000",
                                         pattern => (others => (others => '0')),
                                         color   => "00000000",
                                         active  => '0');

  type     sprite_array_type is array (0 to 7) of sprite_type;

end package sprite_pkg;

