library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pong_tb is
end pong_tb ;

architecture Structural of pong_tb is

    function slv_to_string ( a: std_logic_vector) return string is
    variable b : string (a'length-1 downto 0) := (others => NUL);
    begin
        for i in a'length-1 downto 0 loop
            b(i) := std_logic'image(a(i))(2);
        end loop;
        return b;
    end function;

    --Clock
    signal clk : std_logic; -- 25 MHz
    signal test_running : boolean := true;

    -- slide-switches and push-buttons
    signal sw   : std_logic_vector (7 downto 0);
    signal btn  : std_logic_vector (3 downto 0);

    alias btn_clk     : std_logic is btn(0);
    alias btn_write   : std_logic is btn(1);
    alias btn_reset   : std_logic is btn(2);
    
    alias sw_clk_free : std_logic is sw(0);
    alias sw_runmode  : std_logic is sw(1);

    alias sw_led_select  : std_logic_vector (3 downto 0) is sw(5 downto 2);
    constant LED_SELECT_RAM  : std_logic_vector (3 downto 0) := "0000";
    constant LED_SELECT_ADDR : std_logic_vector (3 downto 0) := "0001";
    constant LED_SELECT_OUT  : std_logic_vector (3 downto 0) := "0010";
    constant LED_SELECT_BUS  : std_logic_vector (3 downto 0) := "0011";
    constant LED_SELECT_ALU  : std_logic_vector (3 downto 0) := "0100";
    constant LED_SELECT_AREG : std_logic_vector (3 downto 0) := "0101";
    constant LED_SELECT_BREG : std_logic_vector (3 downto 0) := "0110";
    constant LED_SELECT_PC   : std_logic_vector (3 downto 0) := "0111";
    constant LED_SELECT_CONL : std_logic_vector (3 downto 0) := "1000";
    constant LED_SELECT_CONH : std_logic_vector (3 downto 0) := "1001";
    constant LED_SELECT_IREG : std_logic_vector (3 downto 0) := "1010";
    constant LED_SELECT_D    : std_logic_vector (3 downto 0) := "1011";
    constant LED_SELECT_E    : std_logic_vector (3 downto 0) := "1100";
    constant LED_SELECT_F    : std_logic_vector (3 downto 0) := "1101";

    alias sw_disp_two_comp : std_logic is sw(6); -- Display two's complement

    -- LED
    signal led : std_logic_vector (7 downto 0);

    -- VGA output
    signal vga_hs  : std_logic;
    signal vga_vs  : std_logic;
    signal vga_col : std_logic_vector(7 downto 0);

begin
    -- Simulate external crystal clock (25 MHz)
    clk_gen : process
    begin
        if not test_running then
            wait;
        end if;

        clk <= '1', '0' after 20 ns;
        wait for 40 ns;
    end process clk_gen;

    -- Instantiate DUT
    inst_pong : entity work.pong
    generic map (
                    SIMULATION => true ,
                    FREQ => 25000000
                )
    port map (
                 clk_i        => clk     ,
                 sw_i         => sw      ,
                 btn_i        => btn     ,
                 --led_o        => led     , 
                 --seg_ca_o     => open    ,
                 --seg_dp_o     => open    ,
                 --seg_an_o     => open    ,
                 vga_hs_o     => vga_hs  ,
                 vga_vs_o     => vga_vs  ,
                 vga_col_o    => vga_col
             );

    -- Start the main test
    main_test : process is

    begin
        btn <= "0000";
        wait for 100 us;
        btn <= "0001";
        wait for 20 ms;
        test_running <= false;
        wait;
    end process main_test;

end Structural;

