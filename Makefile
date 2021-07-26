
TARGET_TOOLCHAIN_ROOT := gcc-arm-none-eabi-10-2020-q4-major/bin/
TARGET_TOOLCHAIN_PREFIX := arm-none-eabi-

# These are microcontroller-specific rules for converting the ELF output
# of the linker into a binary image that can be loaded directly.
CXX             := '$(TARGET_TOOLCHAIN_ROOT)$(TARGET_TOOLCHAIN_PREFIX)g++'
CC              := '$(TARGET_TOOLCHAIN_ROOT)$(TARGET_TOOLCHAIN_PREFIX)gcc'
AS              := '$(TARGET_TOOLCHAIN_ROOT)$(TARGET_TOOLCHAIN_PREFIX)as'
AR              := '$(TARGET_TOOLCHAIN_ROOT)$(TARGET_TOOLCHAIN_PREFIX)ar'
LD              := '$(TARGET_TOOLCHAIN_ROOT)$(TARGET_TOOLCHAIN_PREFIX)ld'
NM              := '$(TARGET_TOOLCHAIN_ROOT)$(TARGET_TOOLCHAIN_PREFIX)nm'
OBJDUMP         := '$(TARGET_TOOLCHAIN_ROOT)$(TARGET_TOOLCHAIN_PREFIX)objdump'
OBJCOPY         := '$(TARGET_TOOLCHAIN_ROOT)$(TARGET_TOOLCHAIN_PREFIX)objcopy'
SIZE            := '$(TARGET_TOOLCHAIN_ROOT)$(TARGET_TOOLCHAIN_PREFIX)size'

RM := 'rm'

CCFLAGS += -Wimplicit-function-declaration -std=c11 -Werror \
-fno-unwind-tables -ffunction-sections -fdata-sections -fmessage-length=0 \
-O3 -Wsign-compare -Wshadow -Wunused-variable \
-Wmissing-field-initializers -Wunused-function -Wswitch -Wvla -Wall -Wextra \
-Wstrict-aliasing -Wno-unused-parameter -mcpu=cortex-m55 -mfpu=auto -mthumb \
-mfloat-abi=hard -funsigned-char -mlittle-endian -Wno-implicit-fallthrough \
-Wno-strict-aliasing -fomit-frame-pointer -MD -DCPU_M55=1 -DARMCM55 \
-I. -Isrc -ICMSIS_5 -ICMSIS_5/Device/ARM/ARMCM55/Include -ICMSIS_5/CMSIS/Core/Include \
-ICMSIS_5/CMSIS/DSP/Include -ICMSIS_5/CMSIS/DSP/PrivateInclude \
-ICMSIS_5/CMSIS/DSP/Include/dsp

LDFLAGS += -Wl,--fatal-warnings -Wl,--gc-sections --specs=nosys.specs \
-T ethos_u_core_platform/targets/corstone-300/platform_parsed.ld \
-Wl,-Map=cortex_m_corstone_300.map,--cref -lm -Wl,--gc-sections \
--entry Reset_Handler -lm

%.o:	%.cc
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

%.o:	%.c
	$(CC) $(CCFLAGS) $(INCLUDES) -c $< -o $@

all:	main.bin

all_objs := src/main.o ethos_u_core_platform/targets/corstone-300/retarget.o \
ethos_u_core_platform/targets/corstone-300/uart.o \
CMSIS_5/Device/ARM/ARMCM55/Source/system_ARMCM55.o \
CMSIS_5/Device/ARM/ARMCM55/Source/startup_ARMCM55.o \
CMSIS_5/CMSIS/DSP/Source/CommonTables/CommonTables.o \
CMSIS_5/CMSIS/DSP/Source/BayesFunctions/BayesFunctions.o \
CMSIS_5/CMSIS/DSP/Source/FastMathFunctions/FastMathFunctions.o \
CMSIS_5/CMSIS/DSP/Source/BasicMathFunctions/BasicMathFunctions.o \
CMSIS_5/CMSIS/DSP/Source/StatisticsFunctions/StatisticsFunctions.o

main:	$(all_objs)
	$(CC) $(CCFLAGS) $(INCLUDES) -o main $(all_objs) $(LDFLAGS)

main.bin:	main
	$(OBJCOPY) main main.bin -O binary

clean:
	-rm $(all_objs) *.map
