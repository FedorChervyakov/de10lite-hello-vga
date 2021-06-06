# Hello VGA
A very basic VGA driver for the Terasic DE10-Lite FPGA board. Current version has only the RTL-based static video memory which generates red, green, and blue vertical stripes of fixed width.

## Requirements
This project uses the Intel Quartus Prime 20.1 Lite for compilation. Other versions might work as well.\
You can also use provided Makefile to compile the design and program your board from command line. For this you need to have **make** installed, and have `$QUARTUS_ROOT/quartus/bin` on your path, where `$QUARTUS_ROOT` contains your Quartus installation.

## Usage
To compile the design (run this command from the top dir):
```
make -C quartus
```
To program your board with .sof:
```
make -C quartus program
```
To program with .pof:
```
make -C quartus program-pof
```

# Acknowledgements
- The project structure and the Makefile are based on the [Altera-Makefile](https://github.com/mfischer/Altera-Makefile) by **mfischer**.


## References and Useful Links
- [mfischer/Altera-Makefile](https://github.com/mfischer/Altera-Makefile)
- [VGA Timings](http://martin.hinner.info/vga/timing.html)
- [VGA Video Signal Format and Timing Specifications](https://javiervalcarce.eu/html/vga-signal-format-timming-specs-en.html)
- [VHDL Tutorial](http://gmvhdl.com/VHDL.html)

---
*Intel and Quartus are trademarks of Intel Corporation or its subsidiaries. Terasic and DE10 are trademarks of Terasic Technologies Inc.* 
