-- Up counter with synchronous reset active low
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity nru_counter is
    generic (N : integer := 10);
    port (
        -- inputs
        nreset : in std_logic; -- synchronous reset active low
        clk    : in std_logic; -- clock input

        -- output
        Q : out std_logic_vector(N-1 downto 0) -- N-bit output
    );
end entity;

architecture A of nru_counter is
begin
    counter: process(clk)
        variable count : std_logic_vector(N-1 downto 0) := (others => '0');
    begin
        if (rising_edge(clk)) then -- latch on rising edge
            if (nreset='0') then
                -- reset
                count := (others => '0');
            else
                -- count
                count := count + '1';
            end if;
        end if;
        Q <= count; -- assign count to the output
    end process;
end architecture A;
