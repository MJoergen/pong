library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.sprite_pkg.all;

entity tb_pong is
end entity tb_pong;

architecture simulation of tb_pong is

  signal running : std_logic := '1';
  signal clk     : std_logic := '1';
  signal rst     : std_logic := '1';
  signal ce      : std_logic := '0';

  signal btn_up    : std_logic;
  signal btn_down  : std_logic;
  signal sprites   : sprite_array_type;
  signal collision : std_logic_vector(0 to 7);

begin

  clk <= running and not clk after 20 ns; -- 25 MHz
  rst <= '1', '0' after 100 ns;

  -- Instantiate DUT
  pong_inst : entity work.pong
    port map (
      clk_i       => clk,
      rst_i       => rst,
      ce_i        => ce,
      btn_up_i    => btn_up,
      btn_down_i  => btn_down,
      sprites_o   => sprites,
      collision_i => collision
    ); -- pong_inst : entity work.pong

  test_proc : process
  begin
    ce        <= '0';
    btn_up    <= '0';
    btn_down  <= '0';
    collision <= (others => '0');

    wait until falling_edge(rst);
    wait for 100 ns;
    wait until rising_edge(clk);

    report "Test started";
    report "Test 0 : Test reset values";
    assert sprites(0).active  = '1';
    assert sprites(1).active  = '1';
    assert sprites(2).active  = '1';
    assert sprites(3).active  = '0';
    assert sprites(4).active  = '0';
    assert sprites(5).active  = '0';
    assert sprites(6).active  = '0';
    assert sprites(7).active  = '0';

    assert sprites(0).pos_x  = 0;
    assert sprites(0).pos_y  = 256;
    assert sprites(1).pos_x  = 512;
    assert sprites(1).pos_y  = 256;
    assert sprites(2).pos_x  = 32;
    assert sprites(2).pos_y  = 32;

    report "Test 1 : frame 1 test";
    ce        <= '1';
    wait until rising_edge(clk);
    ce        <= '0';
    wait until rising_edge(clk);

    assert sprites(0).pos_x  = 0;
    assert sprites(0).pos_y  = 256;
    assert sprites(1).pos_x  = 512;
    assert sprites(1).pos_y  = 255;
    assert sprites(2).pos_x  = 33;
    assert sprites(2).pos_y  = 33;

    report "Test finished";
    running   <= '0';
    wait;
  end process test_proc;

end architecture simulation;

