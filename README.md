# NXP SDK Toolchain
1. Get SDK for required device from nxp.com and extract to any subfolder (e.g. SDK)
2. Create a Makefile where device and SDK is defined. Example:
```
BUILD_FLOW_DIR := build_flow
SDK_DIR := sdk
DEVICE := JN5189
DEVICE_CFLAGS := -DCPU_JN5189HN -mcpu=cortex-m4 -mthumb 
DEVICE_LDFLAGS := -mcpu=cortex-m4 -mthumb
FLASH_SIZE := 294912

include $(BUILD_FLOW_DIR)/sdk.mk
include $(BUILD_FLOW_DIR)/build.mk
```
3. Create a folder containing the application
4. Put the application source code there. Add a `sources.mk` and set source/include paths, like:
```
SRC_FILES=board_utility.c board.c clock_config.c i2c_polling_transfer.c pin_mux.c
$(eval SRC += $(addprefix $(CUR_DIR),$(SRC_FILES)))
```
5. Define an evironment variable `APPNAME` which is defined as the name of the created application folder
6. Create a linker file which is name `APPNAME`.ld (Replace `APPNAME` by the actual application name) and place it in the application folder.
(Linker file examples can be found in SDK)
7. Optionally, define the following environment variables:
- ARM_OBJCOPY
- ARM_OBJDUMP
- ARM_GCC
- PYTHON3