# --------------------------------------------------------
# Custom M2 Makefile
# written by: Jonathan Bohren & Jonathan Fiene
# modified by: Nick McGill
# updated: Sept. 4, 2012
# --------------------------------------------------------

# --------------------------------------------------------
# if you write separate C files to include in main
# add their .o targets to the OBJECTS line below
# (e.g. "OBJECTS = main.o myfile.o")
# --------------------------------------------------------
OBJECTS    = ADC_live_plot.o /m2_libraries/m_usb.o

# --------------------------------------------------------
# if you need to use one of our pre-compiled libraries,
# add it to the line below (e.g. "LIBRARIES = libsaast.a")
# --------------------------------------------------------
LIBRARIES  = 

# --------------------------------------------------------
# Default settings for the M2:
# --------------------------------------------------------
DEVICE     = atmega32u4
CLOCK      = 16000000
 
# --------------------------------------------------------
# you shouldn't change anything below here,
# unless you really know what you're doing
# --------------------------------------------------------

COMPILE = avr-gcc -std=c99 -I /m2_libraries -Wall -Os -DF_CPU=$(CLOCK) -mmcu=$(DEVICE)

# symbolic targets:
all:	main.hex

.c.o:
	$(COMPILE) -c $< -o $@

.S.o:
	$(COMPILE) -x assembler-with-cpp -c $< -o $@

.c.s:
	$(COMPILE) -S $< -o $@

install: flash 

flash: all
	dfu-programmer atmega32u4 erase
	dfu-programmer atmega32u4 flash main.hex

clean:
	rm -f main.hex main.elf $(OBJECTS)

# file targets:
main.elf: $(OBJECTS)
	$(COMPILE) -o main.elf $(OBJECTS) $(LIBRARIES)

main.hex: main.elf
	rm -f main.hex
	avr-objcopy -j .text -j .data -O ihex main.elf main.hex

# Targets for code debugging and analysis:
disasm:	main.elf
	avr-objdump -d main.elf

cpp:
	$(COMPILE) -E main.c
