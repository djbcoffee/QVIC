# QVIC
The Quarter VGA Interface Chip (QVIC) is designed for color video graphics applications that require display on VGA compatible monitors and displays. It provides all the circuitry needed for generating programmable character graphics with a screen resolution of 320 by 240 and 256 colors (8-bit pixel depth) while offering a straightforward host interface making it ideal for embedded microcontroller and microprocessor designs.

The -2C option provides the following features:
* Eight bytes are used to describe each character
* A maximum of 256 characters can be described
* Each character can be shown in two colors
* Each character’s colors are unique and described through two color tables
* A maximum of 256 colors can be displayed on screen

The -4C option provides the following features:
* Sixteen bytes are used to describe each character
* A maximum of 256 characters can be described
* Each character can be shown in four colors
* Each character’s colors are unique and described through four color tables
* A maximum of 256 colors can be displayed on screen

The -16C option provides the following features:
* Thirty-two bytes are used to describe each character
* A maximum of 256 characters can be described
* Each character can be shown in 16 colors
* Each character’s colors are from a common 16-color palette described through a single color table
* A maximum of 16 colors can be displayed on screen

The -64C option provides the following features:
* Sixty-four bytes are used to describe each character
* A maximum of 128 characters can be described
* Each character can be shown in 64 colors
* Each character’s colors are from a common 256-color palette described through a single color table
* A maximum of 256 colors can be displayed on screen

The QVIC project page, with user manual and hardware files, can be found [here](https://sites.google.com/view/m-chips/qvic)

## Archive content

The following files are provided:
* QVIC-2C
	- CycleCounter.vhd - Source code file
	- HorizontalCountRegister.vhd - Source code file
	- HostSramOpRegister.vhd - Source code file
	- HostSync.vhd - Source code file
	- PixelColorRegister.vhd - Source code file
	- QVIC-2C.vhd - Source code file
	- SramAddressRegister.vhd - Source code file
	- SramDataRegister.vhd - Source code file
	- SyncGenerator.vhd - Source code file
	- Universal.vhd - Source code file
	- VerticalCountRegister.vhd - Source code file
	- WorkingRegister.vhd - Source code file
	- QVIC-2C.ucf - Configuration file
	- QVIC-2C.jed - JEDEC Program file
* QVIC-4C
	- CycleCounter.vhd - Source code file
	- HorizontalCountRegister.vhd - Source code file
	- HostSramOpRegister.vhd - Source code file
	- HostSync.vhd - Source code file
	- PixelColorRegister.vhd - Source code file
	- QVIC-4C.vhd - Source code file
	- SramAddressRegister.vhd - Source code file
	- SramDataRegister.vhd - Source code file
	- SyncGenerator.vhd - Source code file
	- Universal.vhd - Source code file
	- VerticalCountRegister.vhd - Source code file
	- WorkingRegister.vhd - Source code file
	- QVIC-4C.ucf - Configuration file
	- QVIC-4C.jed - JEDEC Program file
* QVIC-16C
	- CycleCounter.vhd - Source code file
	- HorizontalCountRegister.vhd - Source code file
	- HostSramOpRegister.vhd - Source code file
	- HostSync.vhd - Source code file
	- PixelColorRegister.vhd - Source code file
	- QVIC-16C.vhd - Source code file
	- SramAddressRegister.vhd - Source code file
	- SramDataRegister.vhd - Source code file
	- SyncGenerator.vhd - Source code file
	- Universal.vhd - Source code file
	- VerticalCountRegister.vhd - Source code file
	- WorkingRegister.vhd - Source code file
	- QVIC-16C.ucf - Configuration file
	- QVIC-16C.jed - JEDEC Program file
* QVIC-64C
	- CycleCounter.vhd - Source code file
	- HorizontalCountRegister.vhd - Source code file
	- HostSramOpRegister.vhd - Source code file
	- HostSync.vhd - Source code file
	- PixelColorRegister.vhd - Source code file
	- QVIC-64C.vhd - Source code file
	- SramAddressRegister.vhd - Source code file
	- SramDataRegister.vhd - Source code file
	- SyncGenerator.vhd - Source code file
	- Universal.vhd - Source code file
	- VerticalCountRegister.vhd - Source code file
	- WorkingRegister.vhd - Source code file
	- QVIC-64C.ucf - Configuration file
	- QVIC-64C.jed - JEDEC Program file
* LICENSE - License text
* README.md - This file

## Prerequisites

Xilinx’s ISE WebPACK Design Suite version 14.7 is required to do a build and can be obtained [here](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive-ise.html)

Familiarity with the use and operation of the Xilinx ISE Design Suite is assumed and beyond the scope of this readme file.

## Installing

Place the source files into any convenient location on your PC.  NOTE:  The Xilinx ISE Design Suite can not handle spaces in directory and file names.

The JEDEC Program files QVIC-2C.jed, QVIC-4C.jed, QVIC-16C.jed, and QVIC-64C.jed were created with Xilinx ISE WebPACK Design Suite version 14.7.  These can be used to program the Xilinx XC9572XL-5VQG64C CPLD without any further setup.  If you wish to do a build continue with the following steps.

Create a project called QVIC-XC, where X is one of the four color numbers, using the XC9572XL CPLD in a VQ64 package with a speed of -5.\
Set the following for the project:\
Top-Level Source Type = HDL\
Synthesis Tool = XST (VHDL/Verilog)\
Simulator ISim (VHDL/Verilog)\
Perferred Language = VHDL\
VHDL Source Analysis Standard = VHDL-93

Add the source code and configuration file to the project.  NOTE:  Universal.vhd needs to set as a global file in the compile list.

Synthesis options need to be set as:  
Input File Name                    : "QVIC_XC.prj"\
Input Format                       : mixed\
Ignore Synthesis Constraint File   : NO\
Output File Name                   : "QVIC_XC"\
Output Format                      : NGC\
Target Device                      : XC9500XL CPLDs\
Top Module Name                    : QVIC_XC\
Automatic FSM Extraction           : NO\
Mux Extraction                     : Yes\
Resource Sharing                   : YES\
Add IO Buffers                     : YES\
MACRO Preserve                     : YES\
XOR Preserve                       : YES\
Equivalent register Removal        : YES\
Optimization Goal                  : Speed\
Optimization Effort                : 1\
Keep Hierarchy                     : Yes\
Netlist Hierarchy                  : As_Optimized\
RTL Output                         : Yes\
Hierarchy Separator                : /\
Bus Delimiter                      : <>\
Case Specifier                     : Maintain\
Verilog 2001                       : YES\
Clock Enable                       : YES\
wysiwyg                            : NO

Fitter options need to be set as:\
Device(s) Specified                         : xc9572xl-5-VQ64\
Optimization Method                         : SPEED\
Multi-Level Logic Optimization              : ON\
Ignore Timing Specifications                : OFF\
Default Register Power Up Value             : LOW\
Keep User Location Constraints              : ON\
What-You-See-Is-What-You-Get                : OFF\
Exhaustive Fitting                          : OFF\
Keep Unused Inputs                          : OFF\
Slew Rate                                   : FAST\
Power Mode                                  : STD\
Ground on Unused IOs                        : ON\
Set I/O Pin Termination                     : KEEPER\
Global Clock Optimization                   : ON\
Global Set/Reset Optimization               : ON\
Global Ouput Enable Optimization            : ON\
Input Limit                                 : 54\
Pterm Limit                                 : 25

The design can now be implemented.

## Built With

* [Xilinx’s ISE WebPACK Design Suite version 14.7](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive-ise.html) - The development, simulation, and programming environment used

## Version History

* v1.0.0 - 2018 
	- Initial release

## Authors

* **Donald J Bartley** - *Initial work* - [djbcoffee](https://github.com/djbcoffee)

## License

This project is licensed under the GNU Public License 2 - see the [LICENSE](LICENSE) file for details
