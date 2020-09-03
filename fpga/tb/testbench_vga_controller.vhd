-- Testbench for the 640x480 VGA controller
library ieee;
use ieee.std_logic_1164.all;

entity testbench_vga_controller is
end entity;

architecture testbench of testbench_vga_controller is
    -- component declaration of the UUT
    -- the VGA controller
    component vga_controller is
        generic (
            -- resolution
            HORIZONTAL    : integer := 640;
            VERTICAL      : integer := 480;

            -- HSYNC specs
            H_FRONT_PORCH : integer := 16;
            H_SYNC_PULSE  : integer := 96;
            H_BACK_PORCH  : integer := 48;

            -- VSYNC specs
            V_FRONT_PORCH : integer := 11;
            V_SYNC_PULSE  : integer := 2;
            V_BACK_PORCH  : integer := 31;

            -- color spec
            COLOR_BITNESS : integer := 4
        );
        port (
            -- inputs
            nreset : in std_logic; -- synchronous reset active low
            clk    : in std_logic; -- pixel clock input
        --  mem_clk: in std_logic; -- video memory clock ??

            -- outputs
            HSYNC : out std_logic; -- horizontal sync
            VSYNC : out std_logic; -- vertical sync

            RED   : out std_logic_vector(COLOR_BITNESS-1 downto 0); -- red channel
            GREEN : out std_logic_vector(COLOR_BITNESS-1 downto 0); -- green channel
            BLUE  : out std_logic_vector(COLOR_BITNESS-1 downto 0)  -- blue channel
        );
    end component;

    -- internal signals
    -- test inputs
    signal nreset, clk : std_logic := '0';
    
    -- test outputs
    signal HSYNC, VSYNC : std_logic;
    signal RED, GREEN, BLUE : std_logic_vector(3 downto 0);
begin
    -- instance of vga_controller
    uut : vga_controller
        port map (
            nreset => nreset, clk => clk,
            HSYNC => HSYNC, VSYNC => VSYNC,
            RED => RED, GREEN => GREEN, BLUE => BLUE
        );

    -- clock generation process
    clock: process
    begin 
        clk <= '1';
        wait for 50 ns;
        clk <= '0';
        wait for 50 ns;
    end process;

    -- test sequence
    tb : process
    begin
        nreset <= '0';
        wait for 150 ns; -- wait 1.5 clock cycles
        nreset <= '1';
        -- test single row
        wait for 80050 ns; -- -50 ns so changes are at falling edges
        -- wait 3 clock cycles
        -- test single frame;
        wait for 41919197 ns;
        -- test reset
--        nreset <= '0';
        wait for 300 ns; -- wait 3 clock cycles
        nreset <= '1';
        wait for 200 ns; -- wait 2 clock cycles
        wait until true;
    end process;

end architecture testbench;

