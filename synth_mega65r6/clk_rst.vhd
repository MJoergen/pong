library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library unisim;
  use unisim.vcomponents.all;

library xpm;
  use xpm.vcomponents.all;

entity clk_rst is
  port (
    clk_i      : in    std_logic; -- System Clock, 100 MHz
    rst_i      : in    std_logic;

    vga_clk_o  : out   std_logic;
    vga_rst_o  : out   std_logic
  );
end entity clk_rst;

architecture synthesis of clk_rst is

  signal pll_fb       : std_logic;
  signal pll_vga_clk  : std_logic;
  signal pll_locked   : std_logic;

begin

  mmcme2_base_inst : component mmcme2_base
    generic map (
      BANDWIDTH          => "OPTIMIZED",
      CLKFBOUT_MULT_F    => 13.500,   -- 1350 MHz
      CLKFBOUT_PHASE     => 0.000,
      CLKIN1_PERIOD      => 10.0,     -- INPUT @ 100 MHz
      CLKOUT0_DIVIDE_F   => 50.000,   -- OUTPUT @ 27.000 MHz
      CLKOUT0_DUTY_CYCLE => 0.500,
      CLKOUT0_PHASE      => 0.000,
      DIVCLK_DIVIDE      => 1,
      REF_JITTER1        => 0.010,
      STARTUP_WAIT       => FALSE
    )
    port map (
      clkin1   => clk_i,
      clkfbin  => pll_fb,
      rst      => rst_i,
      pwrdwn   => '0',
      clkout0  => pll_vga_clk,
      clkfbout => pll_fb,
      locked   => pll_locked
    ); -- mmcme2_base_inst : component mmcme2_base


  bufg_vga_inst : component bufg
    port map (
      i => pll_vga_clk,
      o => vga_clk_o
    ); -- bufg_vga_inst


  xpm_cdc_sync_vga_inst : component xpm_cdc_sync_rst
    generic map (
      DEST_SYNC_FF => 2,
      INIT         => 1
    )
    port map (
      src_rst  => not pll_locked,
      dest_clk => vga_clk_o,
      dest_rst => vga_rst_o
    ); -- xpm_cdc_sync_vga_inst

end architecture synthesis;

