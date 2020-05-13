-- Testbench for the 4 bit up counter with synchronous reset

library ieee;
use ieee.std_logic_1164.all;

entity testbench_counter_4bit is
end entity;

architecture testbench of testbench_counter_4bit is
    -- component declaration of the UUT
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

    -- internal signals
    -- test inputs
    signal nreset, clk : std_logic;
    
    -- test output
    signal Q : std_logic_vector(3 downto 0);
begin
    -- instance of 4-bit up counter with synchronous reset active low
    uut : nru_counter
        generic map (N => 4) 
        port map (nreset => nreset, clk => clk, Q => Q);

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
        nreset <= '1';
        -- test full sequence counting
        wait for 1650 ns; -- -50 ns so changes are at falling edges
        -- test reset
        nreset <= '0';
        wait for 300 ns; -- wait 3 clock cycles
        nreset <= '1';
        wait for 200 ns; -- wait 2 clock cycles
        wait until true;
    end process;

end architecture testbench;

