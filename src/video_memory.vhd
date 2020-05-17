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
    constant w : integer := integer(floor(real(HORIZONTAL)/3.0));
begin
    process (col_addr, row_addr)
        variable r, g, b: std_logic_vector(COLOR_BITNESS-1 downto 0);
    begin
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
        RED <= r;
        GREEN <= g;
        BLUE <= b;
    end process;
end architecture A;
