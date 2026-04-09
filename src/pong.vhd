library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

library work;
  use work.sprite_pkg.all;

entity pong is
  port (
    clk_i       : in    std_logic;
    rst_i       : in    std_logic;
    ce_i        : in    std_logic;

    btn_up_i    : in    std_logic;
    btn_down_i  : in    std_logic;

    sprites_o   : out   sprite_array_type;
    collision_i : in    std_logic_vector(0 to 7)
  );
end entity pong;

architecture synthesis of pong is

  signal   player_y   : natural range 0 to 2047;
  signal   computer_y : natural range 0 to 2047;
  signal   ball_x     : natural range 0 to 2047;
  signal   ball_y     : natural range 0 to 2047;

  signal   sprites : sprite_array_type   := (others => C_NOSPRITE);

  signal   col_clr : std_logic;

  constant C_BITMAP_PLAYER : bitmap_type := (
                                              0  => "1111111100000000",
                                              1  => "1111111100000000",
                                              2  => "1111111100000000",
                                              3  => "1111111100000000",
                                              4  => "1111111100000000",
                                              5  => "1111111100000000",
                                              6  => "1111111100000000",
                                              7  => "1111111100000000",
                                              8  => "1111111100000000",
                                              9  => "1111111100000000",
                                              10 => "1111111100000000",
                                              11 => "1111111100000000",
                                              12 => "1111111100000000",
                                              13 => "1111111100000000",
                                              14 => "1111111100000000",
                                              15 => "1111111100000000"
                                            );

  constant C_BITMAP_COMPUTER : bitmap_type := C_BITMAP_PLAYER;

  constant C_BITMAP_BALL : bitmap_type   := (
                                              0  => "0000000000000000",
                                              1  => "0000111111000000",
                                              2  => "0001111111100000",
                                              3  => "0011111111110000",
                                              4  => "0111111111111000",
                                              5  => "1111111111111100",
                                              6  => "1111111111111100",
                                              7  => "1111111111111100",
                                              8  => "1111111111111100",
                                              9  => "1111111111111100",
                                              10 => "1111111111111100",
                                              11 => "0111111111111000",
                                              12 => "0011111111110000",
                                              13 => "0001111111100000",
                                              14 => "0000111111000000",
                                              15 => "0000000000000000"
                                            );

  constant C_SPRITE_PLAYER   : natural   := 0;
  constant C_SPRITE_COMPUTER : natural   := 1;
  constant C_SPRITE_BALL     : natural   := 2;

  constant C_POS_X_PLAYER   : natural    := 0;
  constant C_POS_X_COMPUTER : natural    := 512;

begin

  sprites_o                  <= sprites;

  sprites(C_SPRITE_PLAYER)   <=
  (
    pos_x  => C_POS_X_PLAYER,
    pos_y  => player_y,
    bitmap => C_BITMAP_PLAYER,
    color  => C_COLOR_GREEN,
    active => '1'
  );

  sprites(C_SPRITE_COMPUTER) <=
  (
    pos_x  => C_POS_X_COMPUTER,
    pos_y  => computer_y,
    bitmap => C_BITMAP_COMPUTER,
    color  => C_COLOR_RED,
    active => '1'
  );

  sprites(C_SPRITE_BALL)     <=
  (
    pos_x  => ball_x,
    pos_y  => ball_y,
    bitmap => C_BITMAP_BALL,
    color  => C_COLOR_YELLOW,
    active => '1'
  );

  -- Instantiate Player
  player_move_inst : entity work.player_move
    port map (
      clk_i      => clk_i,
      rst_i      => rst_i,
      ce_i       => ce_i,
      btn_up_i   => btn_up_i,
      btn_down_i => btn_down_i,
      pos_y_o    => player_y
    ); -- player_move_inst : entity work.player_move

  -- Instantiate Computer
  computer_move_inst : entity work.computer_move
    port map (
      clk_i    => clk_i,
      rst_i    => rst_i,
      ce_i     => ce_i,
      ball_x_i => ball_x,
      ball_y_i => ball_y,
      pos_y_o  => computer_y
    ); -- computer_move_inst : entity work.computer_move

  -- Instantiate Ball
  ball_move_inst : entity work.ball_move
    port map (
      clk_i       => clk_i,
      rst_i       => rst_i,
      ce_i        => ce_i,
      collision_i => collision_i,
      col_clr_o   => col_clr,
      pos_x_o     => ball_x,
      pos_y_o     => ball_y
    ); -- ball_move_inst : entity work.ball_move

end architecture synthesis;

