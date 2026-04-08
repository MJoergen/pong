library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

-- This controls the player

entity player_move is
  generic (
    SIMULATION : boolean := false;
    FREQ       : integer := 25000000 -- Input clock frequency
  );
  port (
    -- Clock
    clk_vs_i   : in    std_logic; -- 60 Hz

    -- Input control
    btn_up_i   : in    std_logic;
    btn_down_i : in    std_logic;

    -- Position
    pos_y_o    : out   std_logic_vector(10 downto 0)
  );
end entity player_move;

architecture structural of player_move is

  signal   pos_y : std_logic_vector(10 downto 0) := "00100000000";

  constant C_SCREEN_Y : integer                  := 480; -- Vertical size of screen
  constant C_HEIGHT   : integer                  := 21;  -- Vertical size of sprite

begin

  pos_y_o <= pos_y;

  pos_proc : process (clk_vs_i)
  begin
    if rising_edge(clk_vs_i) then
      if btn_up_i = '1' and btn_down_i = '0' and pos_y >= 2 then
        pos_y <= pos_y - 2;
      end if;
      if btn_down_i = '1' and btn_up_i = '0' and pos_y < C_SCREEN_Y - C_HEIGHT - 2 then
        pos_y <= pos_y + 2;
      end if;
    end if;
  end process pos_proc;

end architecture structural;

