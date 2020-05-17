-- asynchronous video memory
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all;
use work.utils.all;

entity video_memory is
    generic (
        -- resolution
        HORIZONTAL    : integer := 640;
        VERTICAL      : integer := 480;

        -- color spec
        COLOR_BITNESS : integer := 4;

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
end entity;

architecture A of video_memory is
    subtype pixel_t is std_logic_vector(COLOR_BITNESS*3-1 downto 0);
    type row_t is array(HORIZONTAL-1 downto 0) of pixel_t;
    type pixel_LUT_t is array(VERTICAL-1 downto 0) of row_t;


    -- generate simple striped pattern
    function pattern (row_addr : integer; col_addr : integer)
    return pixel_t is
        variable r, g, b: std_logic_vector(COLOR_BITNESS-1 downto 0);
        variable w : integer;
    begin
        w := integer(floor(real(HORIZONTAL)/3.0));
        if (col_addr < w) then
            r := (others => '1');
            g := (others => '0');
            b := (others => '0');
        elsif (col_addr < w*2) then
            r := (others => '0');
            g := (others => '1');
            b := (others => '0');
        elsif (col_addr < HORIZONTAL-1) then
            r := (others => '0');
            g := (others => '0');
            b := (others => '1');
        end if;
        return r & g & b;
    end pattern;
    
    -- Create look up table
    function init_pixel_LUT
    return pixel_LUT_t is
        variable tmp_table : pixel_LUT_t;
        variable tmp_row   : row_t;
    begin
        for row in 0 to VERTICAL-1 loop
            tmp_row := (others => (others => '0'));
            for col in 0 to HORIZONTAL-1 loop
               tmp_row(col) := pattern(row, col); 
            end loop;
            tmp_table(row) := tmp_row;
        end loop;
        return tmp_table;
    end init_pixel_LUT;

	-- This tells Quartus to create .mif file
	-- Single Uncompressed image with Memory initialization
	-- initialization mode has to be selected
	-- compressed and dual images might work too
    signal pixel_LUT : pixel_LUT_t := init_pixel_LUT;
begin
    process (col_addr, row_addr)
        variable pixel : pixel_t;
        variable temp_row : row_t;
        variable w : integer;
    begin
        w := integer(floor(real(HORIZONTAL)/3.0));
        if (col_addr < w) then
            r := (others => '1');
            g := (others => '0');
            b := (others => '0');
        elsif (col_addr < w*2) then
            r := (others => '0');
            g := (others => '1');
            b := (others => '0');
        elsif (col_addr < HORIZONTAL-1) then
            r := (others => '0');
            g := (others => '0');
            b := (others => '1');
        end if;
        temp_row := pixel_LUT(conv_integer(row_addr));
        pixel := temp_row(conv_integer(col_addr));

        RED <= pixel(COLOR_BITNESS*3-1 downto COLOR_BITNESS*2-1);
        GREEN <= pixel(COLOR_BITNESS*2-1 downto COLOR_BITNESS-1);
        BLUE <= pixel(COLOR_BITNESS-1 downto 0);
    end process;
end architecture A;
