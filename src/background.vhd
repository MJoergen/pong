library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

-- This controls the background

entity background is
  generic (
    SIMULATION : boolean := false;
    FREQ       : integer := 25000000 -- Input clock frequency
  );
  port (
    -- Clock
    clk_i     : in    std_logic; -- 25 MHz
    clk_vs_i  : in    std_logic; -- 60 Hz

    -- Display
    blank_i   : in    std_logic;
    pixel_x_i : in    std_logic_vector(10 downto 0);
    pixel_y_i : in    std_logic_vector(10 downto 0);
    rgb_o     : out   std_logic_vector(7  downto 0)
  );
end entity background;

architecture structural of background is

begin

  rgb_o <= "01010101" when blank_i = '0' else
           "00000000";

end architecture structural;

