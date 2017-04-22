library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
    
package sprite_pkg is
    type pattern_t is array (integer range 0 to 20) of std_logic_vector(0 to 23);

    type sprite_t is record
        pos_x   : std_logic_vector (10 downto 0);
        pos_y   : std_logic_vector (10 downto 0);
        pattern : pattern_t;
        color   : std_logic_vector (7 downto 0);
        active  : std_logic;
    end record sprite_t;

    constant NOSPRITE : sprite_t := (
        pos_x   => "00000000000",
        pos_y   => "00000000000",
        pattern => (others => (others => '0')),
        color   => "00000000",
        active  => '0');

    type sprite_array_t is array (0 to 7) of sprite_t;
end package sprite_pkg;

