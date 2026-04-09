-- Original MEGA65 keyboard driver file by Paul Gardner-Stephen

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity mega65kbd_to_matrix is
  generic (
    G_CLOCK_KHZ : natural
  );
  port (
    clk_i               : in    std_logic;
    rst_i               : in    std_logic;

    -- _steady means that the led stays on steadily
    -- _blinking means that the led is blinking
    -- The colors are specified as BGR (reverse RGB)
    powerled_steady_i   : in    std_logic;
    powerled_col_i      : in    std_logic_vector(23 downto 0);
    driveled_steady_i   : in    std_logic;
    driveled_blinking_i : in    std_logic;
    driveled_col_i      : in    std_logic_vector(23 downto 0);

    matrix_ram_offset_o : out   integer range 0 to 15;
    matrix_dia_o        : out   std_logic_vector(7 downto 0);
    keyram_wea_o        : out   std_logic_vector(7 downto 0);

    delete_o            : out   std_logic;
    return_o            : out   std_logic;
    fastkey_o           : out   std_logic;

    -- RESTORE and capslock are active low
    restore_n_o         : out   std_logic;
    capslock_n_o        : out   std_logic;

    -- LEFT and UP cursor keys are active HIGH
    leftkey_o           : out   std_logic;
    upkey_o             : out   std_logic;

    -- interface to Lattice FPGA
    kio8_o              : out   std_logic; -- clock to keyboard
    kio9_o              : out   std_logic; -- data output to keyboard
    kio10_i             : in    std_logic  -- data input from keyboard
  );
end entity mega65kbd_to_matrix;

architecture synthesis of mega65kbd_to_matrix is

  signal   clock_divider          : integer range 0 to 65535 := 0;
  constant C_CLOCK_DIVIDER_TARGET : natural                  := (G_CLOCK_KHZ * 1000) / 2 / 312500 - 1;

  signal   kbd_clock  : std_logic                            := '0';
  signal   phase      : integer range 0 to 255               := 0;
  signal   sync_pulse : std_logic                            := '0';

  signal   counter : unsigned(26 downto 0)                   := to_unsigned(0, 27);

  signal   output_vector : std_logic_vector(127 downto 0);

  signal   deletekey : std_logic                             := '1';
  signal   returnkey : std_logic                             := '1';
  signal   fastkey   : std_logic                             := '1';

begin

  fsm_proc : process (clk_i)
    variable keyram_write_enable_v : std_logic_vector(7 downto 0);
    variable keyram_offset_v       : integer range 0 to 15 := 0;
  begin
    if rising_edge(clk_i) then
      ------------------------------------------------------------------------
      -- Read from MEGA65 keyboard
      ------------------------------------------------------------------------
      -- Process is to run a clock at a modest rate, and periodically send
      -- a sync pulse, and clock in the key states, while clocking out the
      -- LED states.

      delete_o              <= deletekey;
      return_o              <= returnkey;
      fastkey_o             <= fastkey;

      -- Counter is for working out drive LED blink phase
      counter               <= counter + 1;

      -- Default is no write nothing at offset zero into the matrix ram.
      keyram_write_enable_v := x"00";
      keyram_offset_v       := 0;

      -- modified by sy2002 in December 2022
      if clock_divider /= C_CLOCK_DIVIDER_TARGET then
        clock_divider <= clock_divider + 1;
      else
        clock_divider <= 0;

        kbd_clock     <= not kbd_clock;
        kio8_o        <= kbd_clock or sync_pulse;

        if kbd_clock='1' and phase < 128 then
          keyram_offset_v := phase / 8;

          -- Receive keys with dedicated lines
          if phase = 72 then
            capslock_n_o <= kio10_i;
          end if;
          if phase = 73 then
            upkey_o <= not kio10_i;
          end if;
          if phase = 74 then
            leftkey_o <= not kio10_i;
          end if;
          if phase = 75 then
            restore_n_o <= kio10_i;
          end if;
          if phase = 76 then
            deletekey <= kio10_i;
          end if;
          if phase = 77 then
            returnkey <= kio10_i;
          end if;
          if phase = 78 then
            fastkey <= kio10_i;
          end if;

          -- Work around the data arriving 2 cycles late from the keyboard controller
          if phase = 0 then
            matrix_dia_o <= (others => deletekey);
          elsif phase = 1 then
            matrix_dia_o <= (others => returnkey);
          else
            matrix_dia_o <= (others => kio10_i); -- present byte of input bits to ram for writing
          end if;


          case (phase mod 8) is

            when 0 =>
              keyram_write_enable_v := x"01";

            when 1 =>
              keyram_write_enable_v := x"02";

            when 2 =>
              keyram_write_enable_v := x"04";

            when 3 =>
              keyram_write_enable_v := x"08";

            when 4 =>
              keyram_write_enable_v := x"10";

            when 5 =>
              keyram_write_enable_v := x"20";

            when 6 =>
              keyram_write_enable_v := x"40";

            when 7 =>
              keyram_write_enable_v := x"80";

            when others =>
              null;

          end case;

        end if;
        matrix_ram_offset_o <= keyram_offset_v;
        keyram_wea_o        <= keyram_write_enable_v;

        if kbd_clock='0' then
          -- report "phase = " & integer'image(phase) & ", sync=" & std_logic'image(sync_pulse);
          if phase /= 140 then
            phase <= phase + 1;
          else
            phase <= 0;
          end if;
          if phase = 127 then
            -- Reset to start
            sync_pulse    <= '1';
            output_vector <= (others => '0');
            if driveled_steady_i='1' or (driveled_blinking_i='1' and counter(24)='1') then
              output_vector(23 downto 0)  <= driveled_col_i;
              output_vector(47 downto 24) <= driveled_col_i;
            end if;
            if powerled_steady_i='1' then
              output_vector(71 downto 48) <= powerled_col_i;
              output_vector(95 downto 72) <= powerled_col_i;
            end if;
          elsif phase = 140 then
            sync_pulse <= '0';
          elsif phase < 127 then
            -- Output next bit
            kio9_o                      <= output_vector(127);
            output_vector(127 downto 1) <= output_vector(126 downto 0);
            output_vector(0)            <= '0';
          end if;
        end if;
      end if;

      if rst_i = '1' then
        keyram_wea_o <= (others => '0');
        delete_o     <= '0';
        return_o     <= '0';
        fastkey_o    <= '0';
        restore_n_o  <= '1';
        capslock_n_o <= '1';
        leftkey_o    <= '0';
        upkey_o      <= '0';
      end if;
    end if;
  end process fsm_proc;

end architecture synthesis;

