ifndef APPNAME
$(error APPNAME not defined!)
endif
ifndef ARM_OBJCOPY
ARM_OBJCOPY := arm-none-eabi-objcopy
endif
ifndef ARM_OBJDUMP
ARM_OBJDUMP := arm-none-eabi-objdump
endif
ifndef ARM_GCC
ARM_GCC := arm-none-eabi-gcc
endif
ifndef PYTHON3
PYTHON3 := python3
endif

PWD := $(shell pwd)
BUILD_DIR := build
CUR_DIR = $(dir $(lastword $(MAKEFILE_LIST)))
CFLAGS := -std=gnu99 -D__USE_CMSIS -O2 -fno-common -Wall  -ffunction-sections  -fdata-sections  -ffreestanding  -fno-builtin -fmerge-constants -MMD -MP $(DEVICE_CFLAGS)
LDFLAGS := -specs=nosys.specs -Xlinker --gc-sections -Xlinker -print-memory-usage -Xlinker --sort-section=alignment -Xlinker --cref $(DEVICE_LDFLAGS)
INC_DIRS += $(APPNAME)
include $(APPNAME)/sources.mk
INC := $(addprefix -I,$(INC_DIRS))
OBJS := $(SRC:%.c=%.o)
DEPS := $(OBJS:.o=.d)

.PHONY: all
all: $(APPNAME)/$(APPNAME).bin $(APPNAME)/$(APPNAME).dis

.PHONY: clangd
clangd:
	@$(MAKE) -j1 --always-make --dry-run \
		| grep -w '\-c' \
		| jq -nR '[inputs|{directory:"$(PWD)", command:., file: match(" [^ ]+$$").string[1:]}]' > compile_commands.json

.PHONY: clean
clean:
	@rm -f $(OBJS) $(DEPS) $(APPNAME)/$(APPNAME).axf $(APPNAME)/$(APPNAME).bin $(APPNAME)/$(APPNAME).dis $(APPNAME)/$(APPNAME).map

$(APPNAME)/$(APPNAME).bin: $(APPNAME)/$(APPNAME).axf
	@$(ARM_OBJCOPY) -v -O binary $< $@
	$(info Creating $@)

$(APPNAME)/$(APPNAME).dis: $(APPNAME)/$(APPNAME).axf
	@$(ARM_OBJDUMP) -S --disassemble $< > $@
	$(info Creating $@)

$(APPNAME)/$(APPNAME).axf: $(OBJS)
	@$(ARM_GCC) -Xlinker -Map=$(APPNAME)/$(APPNAME).map -T $(APPNAME)/$(APPNAME).ld $(LDFLAGS) -o $@ $^ && \
	$(PYTHON3) $(SDK_DIR)/tools/imagetool/dk6_image_tool.py -s $(FLASH_SIZE) $@ && rm -f data.bin
	$(info Linking $@)

%.o: %.c
	@$(ARM_GCC) $(CFLAGS) $(INC) -o $@ -c $<
	$(info Compiling $<)

%.o: %.S
	@$(ARM_GCC) $(CFLAGS) $(INC) -o $@ -c $<
	$(info Assembling $<)

-include $(DEPS)
