library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- This controls the player

entity ball_move is

    generic (
                SIMULATION : boolean := false;
                FREQ       : integer := 25000000 -- Input clock frequency
            );
    port (
             -- Clock
             clk_vs_i     : in  std_logic;  -- 60 Hz

             -- Input control
             player_y_i   : in  std_logic_vector (10 downto 0);
             computer_y_i : in  std_logic_vector (10 downto 0);

             -- Position
             pos_x_o      : out std_logic_vector (10 downto 0);
             pos_y_o      : out std_logic_vector (10 downto 0)
         );

end ball_move;

architecture Structural of ball_move is

    signal vel_x : integer := 4;
    signal vel_y : integer := 4;
    signal pos_x : std_logic_vector (10 downto 0) := "00010000000";
    signal pos_y : std_logic_vector (10 downto 0) := "00010000000";

    constant screen_y : integer := 480; -- Vertical size of screen

begin

    pos_x_o <= pos_x;
    pos_y_o <= pos_y;

    process (clk_vs_i)
    begin
        if rising_edge(clk_vs_i) then
            pos_x <= pos_x + vel_x;

            if vel_y > 0 then -- We are moving down
                if pos_y > screen_y - vel_y then
                    vel_y <=  - vel_y;
                end if;
            else -- We are moving up
                if pos_y < - vel_y then
                    vel_y <=  - vel_y;
                end if;
            end if;
            pos_y <= pos_y + vel_y;
        end if;
    end process;

end Structural;

