library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

-- This controls the player

entity ball_move is
  generic (
    SIMULATION : boolean := false;
    FREQ       : integer := 25000000 -- Input clock frequency
  );
  port (
    -- Clock
    clk_vs_i    : in    std_logic; -- 60 Hz

    -- Collision detect
    collision_i : in    std_logic_vector(0 to 7);
    col_clr_o   : out   std_logic;

    -- Position
    pos_x_o     : out   std_logic_vector(10 downto 0);
    pos_y_o     : out   std_logic_vector(10 downto 0)
  );
end entity ball_move;

architecture structural of ball_move is

  signal   vel_x : integer                       := 8;
  signal   vel_y : integer                       := 8;
  signal   pos_x : std_logic_vector(13 downto 0) := "00100000000000";
  signal   pos_y : std_logic_vector(13 downto 0) := "00100000000000";

  constant C_SCREEN_Y : integer                  := 480 * 8; -- Vertical size of screen
  constant C_HEIGHT   : integer                  := 7;       -- Vertical size of sprite

begin

  pos_x_o   <= pos_x(13 downto 3);
  pos_y_o   <= pos_y(13 downto 3);

  col_clr_o <= '0';

  pos_proc : process (clk_vs_i)
  begin
    if rising_edge(clk_vs_i) then
      if collision_i /= "00000000" then
        pos_x <= pos_x - vel_x;
        if vel_x > 0 then
          vel_x <= - vel_x - 1;
        else
          vel_x <= - vel_x + 1;
        end if;
      else
        pos_x <= pos_x + vel_x;
      end if;

      if vel_y > 0 then                               -- We are moving down
        if pos_y + vel_y + C_HEIGHT > C_SCREEN_Y then
          pos_y <= pos_y - vel_y;
          vel_y <= - vel_y;
        else
          pos_y <= pos_y + vel_y;
        end if;
      else                                            -- We are moving up
        if pos_y < - vel_y then
          pos_y <= pos_y - vel_y;
          vel_y <= - vel_y;
        else
          pos_y <= pos_y + vel_y;
        end if;
      end if;
    end if;
  end process pos_proc;

end architecture structural;

