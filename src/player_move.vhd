library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- This controls the player

entity player_move is

    generic (
                SIMULATION : boolean := false;
                FREQ       : integer := 25000000 -- Input clock frequency
            );
    port (
             -- Clock
             clk_vs_i   : in  std_logic;  -- 60 Hz

             -- Input control
             btn_up_i   : in  std_logic;
             btn_down_i : in  std_logic;

             -- Position
             pos_y_o    : out std_logic_vector (10 downto 0)
         );

end player_move;

architecture Structural of player_move is

    constant pos_x  : std_logic_vector (10 downto 0) := "00000000000";
    signal pos_y    : std_logic_vector (10 downto 0) := "00100000000";

    constant size_x : std_logic_vector (10 downto 0) := "00000000111";
    constant size_y : std_logic_vector (10 downto 0) := "00000111111";

begin

    pos_y_o <= pos_y;

    process (clk_vs_i)
    begin
        if rising_edge(clk_vs_i) then
            if btn_up_i = '1' and btn_down_i = '0' and pos_y /= "00000000000" then
                pos_y <= pos_y - 1;
            end if;
            if btn_down_i = '1' and btn_up_i = '0' and pos_y /= "00110000000" then
                pos_y <= pos_y + 1;
            end if;
        end if;
    end process;

end Structural;

