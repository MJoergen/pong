library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

-- This controls the computer

entity computer_move is
  generic (
    SIMULATION : boolean := false;
    FREQ       : integer := 25000000 -- Input clock frequency
  );
  port (
    -- Clock
    clk_vs_i : in    std_logic; -- 60 Hz

    -- Input control
    ball_x_i : in    std_logic_vector(10 downto 0);
    ball_y_i : in    std_logic_vector(10 downto 0);

    -- Position
    pos_y_o  : out   std_logic_vector(10 downto 0)
  );
end entity computer_move;

architecture structural of computer_move is

  signal   pos_y : std_logic_vector(10 downto 0) := "00100000000";

  constant C_BALL_HEIGHT     : integer           := 7;   -- Vertical size of ball sprite
  constant C_COMPUTER_HEIGHT : integer           := 21;  -- Vertical size of computer sprite
  constant C_SCREEN_Y        : integer           := 480; -- Vertical size of screen

begin

  pos_y_o <= pos_y;

  pos_proc : process (clk_vs_i)
  begin
    if rising_edge(clk_vs_i) then
      if ball_y_i + C_BALL_HEIGHT / 2 > pos_y + C_COMPUTER_HEIGHT / 2 and pos_y + 1 + C_COMPUTER_HEIGHT < C_SCREEN_Y then
        pos_y <= pos_y + 1;
      end if;
      if ball_y_i + C_BALL_HEIGHT / 2 < pos_y + C_COMPUTER_HEIGHT / 2 and pos_y > 1 then
        pos_y <= pos_y - 1;
      end if;
    end if;
  end process pos_proc;

end architecture structural;

