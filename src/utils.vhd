-- utility functions
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all;

package utils is
    -- calculate min register width to store N-1
    function min_register_width(N : integer) return integer;
end package;

package body utils is
    -- calculate min register width to store N-1
    function min_register_width(N : integer)
    return integer is
        variable exponent : real;
    begin
        exponent := ceil(log2(real(N)));
        return integer(exponent);
    end min_register_width;
end package body utils;
