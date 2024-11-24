DEVICE_DIR := $(SDK_DIR)/devices/$(DEVICE)
DRIVER_DIR := $(DEVICE_DIR)/drivers
CMSIS_DIR := $(SDK_DIR)/CMSIS

INC_DIRS += $(DEVICE_DIR)/utilities/debug_console \
			$(SDK_DIR)/components/serial_manager \
			$(DEVICE_DIR) \
			$(DRIVER_DIR) \
			$(CMSIS_DIR)/Include

SRC += $(wildcard $(DRIVER_DIR)/fsl_*.c) \
		$(DEVICE_DIR)/system_$(DEVICE).c \
		$(DEVICE_DIR)/gcc/startup_$(DEVICE).c
