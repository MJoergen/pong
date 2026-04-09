library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

-- This controls the computer

entity computer_move is
  generic (
    G_BALL_HEIGHT     : integer := 7;  -- Vertical size of ball sprite
    G_COMPUTER_HEIGHT : integer := 21; -- Vertical size of computer sprite
    G_SCREEN_Y        : integer := 480 -- Vertical size of screen
  );
  port (
    -- Clock
    clk_i    : in    std_logic;
    rst_i    : in    std_logic;
    ce_i     : in    std_logic;

    -- Input control
    ball_x_i : in    natural range 0 to 2047;
    ball_y_i : in    natural range 0 to 2047;

    -- Position
    pos_y_o  : out   natural range 0 to 2047
  );
end entity computer_move;

architecture structural of computer_move is

  signal pos_y : natural range 0 to 2047 := 256;

begin

  pos_y_o <= pos_y;

  pos_proc : process (clk_i, ce_i)
  begin
    if rising_edge(clk_i) and ce_i = '1' then
      if ball_y_i + G_BALL_HEIGHT / 2 > pos_y + G_COMPUTER_HEIGHT / 2 and
         pos_y + 1 + G_COMPUTER_HEIGHT < G_SCREEN_Y then
        pos_y <= pos_y + 1;
      end if;
      if ball_y_i + G_BALL_HEIGHT / 2 < pos_y + G_COMPUTER_HEIGHT / 2 and
         pos_y > 1 then
        pos_y <= pos_y - 1;
      end if;
      if rst_i = '1' then
        pos_y <= 256;
      end if;
    end if;
  end process pos_proc;

end architecture structural;

