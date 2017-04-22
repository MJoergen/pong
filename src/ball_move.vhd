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

    signal vel_x : std_logic_vector (10 downto 0) := "00000000100";
    signal vel_y : std_logic_vector (10 downto 0) := "00000000100";
    signal pos_x : std_logic_vector (10 downto 0) := "00010000000";
    signal pos_y : std_logic_vector (10 downto 0) := "00010000000";

begin

    pos_x_o <= pos_x;
    pos_y_o <= pos_y;

end Structural;

