library ieee;
use ieee.std_logic_1164.all;

entity hello_vga is
    port (
        -- inputs
        MAX10_CLK1_50 : in std_logic;
        KEY            : in std_logic_vector(1 downto 0);

        -- outputs
        LEDR   : out std_logic_vector(9 downto 0);
        VGA_R  : out std_logic_vector(3 downto 0);
        VGA_G  : out std_logic_vector(3 downto 0);
        VGA_B  : out std_logic_vector(3 downto 0);
        VGA_HS : out std_logic;
        VGA_VS : out std_logic
    );
end entity;

architecture A of hello_vga is
    -- pixel clock
    component pll is
        port (
            areset : in std_logic  := '0';
            inclk0 : in std_logic  := '0';
            c0     : out std_logic ;
            locked : out std_logic
        );
    end component;

    -- vga controller
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
            V_FRONT_PORCH : integer := 10;
            V_SYNC_PULSE  : integer := 2;
            V_BACK_PORCH  : integer := 33;

            -- color spec
            COLOR_BITNESS : integer := 4
        );
        port (
            -- inputs
            nreset : in std_logic; -- synchronous reset active low
            clk    : in std_logic; -- pixel clock input

            -- outputs
            HSYNC : out std_logic; -- horizontal sync
            VSYNC : out std_logic; -- vertical sync

            RED   : out std_logic_vector(COLOR_BITNESS-1 downto 0); -- red channel
            GREEN : out std_logic_vector(COLOR_BITNESS-1 downto 0); -- green channel
            BLUE  : out std_logic_vector(COLOR_BITNESS-1 downto 0)  -- blue channel
        );
    end component;

    signal reset, areset, clk : std_logic;
begin
    reset <= KEY(0);
    areset <= not reset;

    pixel_clock : pll
    port map (areset => areset, inclk0 => MAX10_CLK1_50, c0 => clk, locked => LEDR(0));

    vga_ctrl : vga_controller
    port map (nreset => reset, clk => clk, HSYNC => VGA_HS, VSYNC => VGA_VS,
              RED => VGA_R, GREEN => VGA_G, BLUE => VGA_B);

end architecture A;
