-- VGA controller
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all;

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

    -- calculate min counter width
    function min_counter_width(N : integer)
    return integer is
        variable exponent : real;
    begin
        exponent := ceil(log2(real(N)));
        return integer(exponent);
    end min_counter_width;

    -- constants
    constant N_col : -- total number of columns in a row in a frame
        integer := HORIZONTAL+H_FRONT_PORCH+H_SYNC_PULSE+H_BACK_PORCH;
    constant N_row : -- total number of rows in a frame
        integer := VERTICAL+V_FRONT_PORCH+V_SYNC_PULSE+V_BACK_PORCH;
    constant col_counter_width : -- width of column counter
        integer := min_counter_width(N_col);
    constant row_counter_width : -- width of row counter
        integer := min_counter_width(N_row);

    -- counter signals
    signal Q_col : std_logic_vector(col_counter_width-1 downto 0)
        := (others => '0'); -- column
    signal Q_row : std_logic_vector(row_counter_width-1 downto 0)
        := (others => '0'); -- row

    -- counter resets;
    signal col_reset : std_logic;
    signal row_reset : std_logic;

    signal row_clock : std_logic; -- row clock
begin
    -- column counter
    col_counter : nru_counter
        generic map (N => col_counter_width)
        port map (nreset => col_reset, clk => clk, Q => Q_col);

    -- row counter
    row_counter : nru_counter
        generic map (N => row_counter_width)
        port map (nreset => row_reset, clk => row_clock, Q => Q_row);

    -- TODO: video memory


    -- column counter reset
    col_reset <= '0' when Q_col >= N_col-1 or nreset='0' else
                 '1' ;

    -- row counter reset
    row_reset <= '0' when Q_row >= N_row-1 or nreset='0' else
                 '1' ;

    -- row clock generation process
    generate_row_clock : process(clk, Q_col)
        variable res : std_logic := '1';
    begin
        -- the process
        if (rising_edge(clk)) then
            if (Q_col=(N_col-1)) then
                res := '1';
            else
                res := '0';
            end if;
        end if;
        row_clock <= res;
    end process;

    -- hsync generation process
    -- vsync generation process
end architecture A;
