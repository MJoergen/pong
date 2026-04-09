library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

-- This controls the player

entity ball_move is
  generic (
    G_SCREEN_Y : integer := 480 * 8; -- Vertical size of screen
    G_HEIGHT   : integer := 7        -- Vertical size of sprite
  );
  port (
    -- Clock
    clk_i       : in    std_logic;
    rst_i       : in    std_logic;
    ce_i        : in    std_logic;

    -- Collision detect
    collision_i : in    std_logic_vector(0 to 7);
    col_clr_o   : out   std_logic;

    -- Position
    pos_x_o     : out   natural range 0 to 2047;
    pos_y_o     : out   natural range 0 to 2047
  );
end entity ball_move;

architecture structural of ball_move is

  signal vel_x : integer                 := 8;
  signal vel_y : integer                 := 8;
  signal pos_x : natural range 0 to 2047 := 256;
  signal pos_y : natural range 0 to 2047 := 256;

begin

  pos_x_o   <= pos_x / 8;
  pos_y_o   <= pos_y / 8;

  col_clr_o <= '0';

  pos_proc : process (clk_i, ce_i)
  begin
    if rising_edge(clk_i) and ce_i = '1' then
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
        if pos_y + vel_y + G_HEIGHT > G_SCREEN_Y then
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
      if rst_i = '1' then
        pos_x <= 256;
        pos_y <= 256;
      end if;
    end if;
  end process pos_proc;

end architecture structural;

