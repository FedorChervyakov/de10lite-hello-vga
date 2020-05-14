-- VGA controller
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity vga_controller is
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
end entity;

architecture A of vga_controller is
    -- the N-bit up counter with synchronous reset active low
    component nru_counter is
        generic (N : integer);
        port (
            -- inputs
            nreset : in std_logic; -- synchronous reset active low
            clk    : in std_logic; -- clock input

            -- output
            Q : out std_logic_vector(N-1 downto 0) -- N-bit output
        );
    end component;

    -- counter signals
    signal Q_col : std_logic_vector(9 downto 0) := (others => '0'); -- column
    signal Q_row : std_logic_vector(9 downto 0) := (others => '0'); -- row 
    
    signal row_clock : std_logic; -- row clock
begin
    -- column counter
    col_counter : nru_counter
        generic map (N => 10) 
        port map (nreset => nreset, clk => clk, Q => Q_col );

    -- row counter
    row_counter : nru_counter
        generic map (N => 10) 
        port map (nreset => nreset, clk => row_clock, Q => Q_row);

    -- TODO: video memory

    -- row clock generation process
    generate_row_clock : process(clk, Q_col)
    begin
        -- the process
    end process;

    -- hsync generation process
    -- vsync generation process
end architecture A;
