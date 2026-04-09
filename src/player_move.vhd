library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

-- This controls the player

entity player_move is
  generic (
    G_SCREEN_Y : natural := 480; -- Vertical size of screen
    G_HEIGHT   : natural := 21   -- Vertical size of sprite
  );
  port (
    -- Clock
    clk_i      : in    std_logic;
    rst_i      : in    std_logic;
    ce_i       : in    std_logic;

    -- Input control
    btn_up_i   : in    std_logic;
    btn_down_i : in    std_logic;

    -- Position
    pos_y_o    : out   natural range 0 to 2047
  );
end entity player_move;

architecture structural of player_move is

  signal pos_y : natural range 0 to 2047 := 256;

begin

  pos_y_o <= pos_y;

  pos_proc : process (clk_i, ce_i)
  begin
    if rising_edge(clk_i) and ce_i = '1' then
      if btn_up_i = '1' and btn_down_i = '0' and pos_y >= 2 then
        pos_y <= pos_y - 2;
      end if;
      if btn_down_i = '1' and btn_up_i = '0' and pos_y < G_SCREEN_Y - G_HEIGHT - 2 then
        pos_y <= pos_y + 2;
      end if;
      if rst_i = '1' then
        pos_y <= 256;
      end if;
    end if;
  end process pos_proc;

end architecture structural;

