# --------------------------------------------------------
# Custom M2 Makefile
# written by: Jonathan Bohren & Jonathan Fiene
# modified by: Nick McGill
# updated: Sept. 4, 2012
# --------------------------------------------------------

# --------------------------------------------------------
# if you write separate C files to include in ADC_live_plot
# add their .o targets to the OBJECTS line below
# (e.g. "OBJECTS = ADC_live_plot.o myfile.o")
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
all:	ADC_live_plot.hex

.c.o:
	$(COMPILE) -c $< -o $@

.S.o:
	$(COMPILE) -x assembler-with-cpp -c $< -o $@

.c.s:
	$(COMPILE) -S $< -o $@

install: flash 

flash: all
	dfu-programmer atmega32u4 erase
	dfu-programmer atmega32u4 flash ADC_live_plot.hex

clean:
	rm -f ADC_live_plot.hex ADC_live_plot.elf $(OBJECTS)

# file targets:
ADC_live_plot.elf: $(OBJECTS)
	$(COMPILE) -o ADC_live_plot.elf $(OBJECTS) $(LIBRARIES)

ADC_live_plot.hex: ADC_live_plot.elf
	rm -f ADC_live_plot.hex
	avr-objcopy -j .text -j .data -O ihex ADC_live_plot.elf ADC_live_plot.hex

# Targets for code debugging and analysis:
disasm:	ADC_live_plot.elf
	avr-objdump -d ADC_live_plot.elf

cpp:
	$(COMPILE) -E ADC_live_plot.c
