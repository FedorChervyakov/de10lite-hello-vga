-- VGA controller
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.utils.all;

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

    -- asynchronous video memory
    component video_memory is
        generic (
            -- resolution
            HORIZONTAL    : integer;
            VERTICAL      : integer;

            -- color spec
            COLOR_BITNESS : integer;

            -- address width
            H_ADDR_WIDTH : integer;
            V_ADDR_WIDTH : integer
        );
        port (
            -- pixel address inputs
            col_addr : in std_logic_vector(H_ADDR_WIDTH-1 downto 0);
            row_addr : in std_logic_vector(V_ADDR_WIDTH-1 downto 0);

            -- outputs
            RED   : out std_logic_vector(COLOR_BITNESS-1 downto 0); -- red channel
            GREEN : out std_logic_vector(COLOR_BITNESS-1 downto 0); -- green channel
            BLUE  : out std_logic_vector(COLOR_BITNESS-1 downto 0)  -- blue channel
        );
    end component;

    -- constants
    constant N_col : -- total number of columns in a row in a frame
        integer := HORIZONTAL+H_FRONT_PORCH+H_SYNC_PULSE+H_BACK_PORCH;
    constant N_row : -- total number of rows in a frame
        integer := VERTICAL+V_FRONT_PORCH+V_SYNC_PULSE+V_BACK_PORCH;
    constant col_counter_width : -- width of column counter
        integer := min_register_width(N_col);
    constant row_counter_width : -- width of row counter
        integer := min_register_width(N_row);

    -- counter signals
    signal Q_col : std_logic_vector(col_counter_width-1 downto 0)
        := (others => '0'); -- column
    signal Q_row : std_logic_vector(row_counter_width-1 downto 0)
        := (others => '0'); -- row

    -- counter resets active low;
    signal col_reset : std_logic;
    signal row_reset : std_logic;

    signal row_clock : std_logic; -- row clock

    -- temporary color signals
    signal RED_tmp   : std_logic_vector(COLOR_BITNESS-1 downto 0) := (others => '1');
    signal GREEN_tmp : std_logic_vector(COLOR_BITNESS-1 downto 0) := (others => '1');
    signal BLUE_tmp  : std_logic_vector(COLOR_BITNESS-1 downto 0) := (others => '1');

    -- video blanking active high
    signal video_blank : std_logic;
begin
    -- column counter
    col_counter : nru_counter
        generic map (N => col_counter_width)
        port map (nreset => col_reset, clk => clk, Q => Q_col);

    -- row counter
    row_counter : nru_counter
        generic map (N => row_counter_width)
        port map (nreset => row_reset, clk => row_clock, Q => Q_row);

    -- asynchronous video memory
    video_mem : video_memory
        generic map (HORIZONTAL => HORIZONTAL,
                     VERTICAL => VERTICAL, COLOR_BITNESS => COLOR_BITNESS,
                     H_ADDR_WIDTH => col_counter_width,
                     V_ADDR_WIDTH => row_counter_width)
        port map (col_addr => Q_col, row_addr => Q_row,
                  RED => RED_tmp, GREEN => GREEN_tmp, BLUE => BLUE_tmp);

    -- column counter nreset
    col_reset <= '0' when Q_col >= N_col-1 or nreset='0' else
                 '1' ;

    -- row counter nreset
    row_reset <= '0' when Q_row >= N_row-1 or nreset='0' else
                 '1' ;

    -- video blanking
    video_blank <= '0' when nreset='0' or (Q_col < HORIZONTAL and Q_row < VERTICAL) else
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
    generate_hsync : process(clk, Q_col)
        variable res : std_logic := '0';
    begin
        if (rising_edge(clk)) then
            if (Q_col > N_col-H_BACK_PORCH-1) then
                -- back porch
                res := '1';
            elsif (Q_col > HORIZONTAL+H_FRONT_PORCH-1) then
                -- sync pulse
                res := '0';
            elsif (Q_col > HORIZONTAL-1) then
                -- front porch
                res := '1';
            else
                -- active video
                res := '1';
            end if;
            HSYNC <= res or not nreset;
        end if;
    end process;

    -- vsync generation process
    generate_vsync : process(row_clock, Q_row)
        variable res : std_logic := '0';
    begin
        if (rising_edge(row_clock)) then
            if (Q_row > N_row-V_BACK_PORCH-1) then
                -- back porch
                res := '1';
            elsif (Q_row > VERTICAL+V_FRONT_PORCH-1) then
                -- sync pulse
                res := '0';
            elsif (Q_row > VERTICAL-1) then
                -- front porch
                res := '1';
            else
                -- active video
                res := '1';
            end if;
            VSYNC <= res or not nreset;
        end if;
    end process;

    -- color output process
    color_out : process(clk, video_blank, RED_tmp, GREEN_tmp, BLUE_tmp)
        variable r, g, b : std_logic_vector(COLOR_BITNESS-1 downto 0);
    begin
        if (rising_edge(clk)) then
            if (video_blank='0') then
                r := RED_tmp;
                g := GREEN_tmp;
                b := BLUE_tmp;
            else
                r := (others => '0');
                g := (others => '0');
                b := (others => '0');
            end if;
            RED <= r;
            GREEN <= g;
            BLUE <= b;
        end if;
    end process;

    -- color generation process
end architecture A;
