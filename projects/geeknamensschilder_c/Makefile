# Your target ($TARGET without .pde extension)
# Default: helloworld 
TARGET = testapp

# CPU and Clock-frequency settings
# Default: atmega328p with 16MHz (16000000L)
MCU = atmega328p
F_CPU = 16000000L

# Avrdude settings
AVRDUDE_PART = m328p
AVRDUDE_PROG = stk500v1
AVRDUDE_PORT = /dev/ttyUSB0
AVRDUDE_BAUD = 57600

# Do not change anything below this line unless
# you really know what you're doing

BASEPATH = hardware/cores/arduino

SRC = $(BASEPATH)/wiring.c \
$(BASEPATH)/pins_arduino.c \
$(BASEPATH)/wiring_analog.c \
$(BASEPATH)/wiring_digital.c \
$(BASEPATH)/wiring_pulse.c \
$(BASEPATH)/wiring_shift.c \
$(BASEPATH)/WInterrupts.c

CXXSRC = \
$(BASEPATH)/HardwareSerial.cpp \
$(BASEPATH)/WMath.cpp \
$(BASEPATH)/Print.cpp

FORMAT = ihex
MAKEFILE = Makefile

CDEFS = -DF_CPU=$(F_CPU)
CXXDEFS = -DF_CPU=$(F_CPU)
CINCLUDES = -I$(BASEPATH)
CXXINCLUDES = -I$(BASEPATH)

# Compiler + linker flags
# Default setting: Optimize for size (-Os)
CFLAGS = -g $(CINCLUDES) -Os $(CDEFS)
CXXFLAGS = -g $(CXXINCLUDES) -Os $(CDEFS)
LDFLAGS = -lm

# Binary paths (This is the stand-alone version, so we'll
# be using some relative paths). Sorry.
AR = avr-ar
CC = avr-gcc
CXX = avr-g++
NM = avr-nm
OBJDUMP = avr-objdump
OBJCOPY = avr-objcopy
AVRDUDE = hardware/tools/avrdude
SIZE = avr-size
RM = rm -f
MV = mv -f

# Objects and lists
OBJ = $(SRC:.c=.o) $(CXXSRC:.cpp=.o) $(ASRC:.S=.o)
LST = $(ASRC:.S=.lst) $(CXXSRC:.cpp=.lst) $(SRC:.c=.lst)

ALL_CFLAGS = -mmcu=$(MCU) -I. $(CFLAGS)
ALL_CXXFLAGS = -mmcu=$(MCU) -I. $(CXXFLAGS)
ALL_ASFLAGS = -mmcu=$(MCU) -I. -x assembler-with-cpp

all: source elf hex

source: $(TARGET).pde
	@test -d applet || mkdir applet
	@echo "#include \"WProgram.h\"" > applet/$(TARGET).cpp
	@echo "extern \"C\" void __cxa_pure_virtual() {}" >> applet/$(TARGET).cpp
	@cat $(TARGET).pde >> applet/$(TARGET).cpp
	@cat $(BASEPATH)/main.cxx >> applet/$(TARGET).cpp

elf: applet/$(TARGET).elf
hex: applet/$(TARGET).hex
eep: applet/$(TARGET).eep
sym: applet/$(TARGET).sym
lss: applet/$(TARGET).lss

coff: applet/$(TARGET).elf
	$(COFFCONVERT) -O coff-avr applet/$(TARGET).elf $(TARGET).cof

extcoff: applet/$(TARGET).elf
	$(COFFCONVERT) -O coff-ext-avr applet/$(TARGET).elf $(TARGET).cof

.SUFFIXES: .eep .elf .hex .sym .lss

.elf.hex:
	@echo "Building iHex file."
	@$(OBJCOPY) -O $(FORMAT) -R .eeprom $< $@

.elf.eep:
	@echo "Building eeprom file."
	@$(OBJCOPY) -j .eeprom --set-section-flags=.eeprom="alloc,load" \
	--change-section-lma .eeprom=0 -O $(FORMAT) $< $@

.elf.lss:
	$(OBJDUMP) -h -S $< > $@

.elf.sym:
	$(NM) -n $< > $@

applet/$(TARGET).elf: $(TARGET).pde applet/core.a
	@echo "Preparing."
	@$(CC) $(ALL_CFLAGS) -o $@ applet/$(TARGET).cpp -L. applet/core.a $(LDFLAGS)

applet/core.a: $(OBJ)
	@echo "Building core.a."
	@for i in $(OBJ); do echo "Packaging '"$$i"'"; $(AR) rcs applet/core.a $$i; done

.cpp.o:
	@echo "Building C++ Source file $@."
	@$(CXX) -c $(ALL_CXXFLAGS) $< -o $@

.c.o:
	@echo "Building C Source file $@."
	@$(CC) -c $(ALL_CFLAGS) $< -o $@

.c.s:
	@echo "Building Assembler Source file $@."
	@$(CC) -S $(ALL_CFLAGS) $< -o $@

.S.o:
	@echo "Building object."
	@$(CC) -c $(ALL_ASFLAGS) $< -o $@

flash:
	@echo "Resetting *duino target."
	@perl tools/dtr_on.pl
	@echo "Spawning avrdude."
	@$(AVRDUDE) -p $(AVRDUDE_PART) -c $(AVRDUDE_PROG) -U flash:w:applet/$(TARGET).hex -P $(AVRDUDE_PORT) -b $(AVRDUDE_BAUD)
	@echo "All done. Have fun with your *duino."

clean:
	$(RM) applet/$(TARGET).hex applet/$(TARGET).eep applet/$(TARGET).cof \
	applet/$(TARGET).map applet/$(TARGET).elf applet/$(TARGET).sym \
	applet/$(TARGET).lss applet/core.a \
	$(OBJ) $(LST) $(SRC:.c=.s) $(SRC:.c=.d) $(CXXSRC:.cpp=.s) $(CXXSRC:.cpp=.d)

depend:
	if grep '^# Mark - do not delete' $(MAKEFILE) > /dev/null
	then \
		sed -e '/^# Mark - do not delete/,$$d' $(MAKEFILE) > \
		$(MAKEFILE).$$$$ && \
		$(MV) $(MAKEFILE).$$$$ $(MAKEFILE); \
	fi
	echo "# Mark - do not delete" >> $(MAKEFILE); \
	$(CC) -M -mmcu=$(MCU) $(CDEFS) $(CINCS) $(SRC) $(ASRC) >> $(MAKEFILE)

# Mark - do not delete
