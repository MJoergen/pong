library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- This controls the computer

entity computer_move is

    generic (
                SIMULATION : boolean := false;
                FREQ       : integer := 25000000 -- Input clock frequency
            );
    port (
             -- Clock
             clk_vs_i   : in  std_logic;  -- 60 Hz

             -- Input control
             ball_x_i   : in  std_logic_vector (10 downto 0);
             ball_y_i   : in  std_logic_vector (10 downto 0);

             -- Position
             pos_y_o    : out std_logic_vector (10 downto 0)
         );

end computer_move;

architecture Structural of computer_move is

    signal pos_y    : std_logic_vector (10 downto 0) := "00100000000";

begin

    pos_y_o <= pos_y;

    process (clk_vs_i)
    begin
        if rising_edge(clk_vs_i) then
            if ball_y_i > pos_y then
                pos_y <= pos_y + 1;
            end if;
            if ball_y_i < pos_y then
                pos_y <= pos_y - 1;
            end if;
        end if;
    end process;

end Structural;

