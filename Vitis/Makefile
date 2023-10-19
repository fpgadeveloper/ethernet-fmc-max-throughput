# Opsero Electronic Design Inc. 2023
#
# This Makefile can be used to build the Vitis workspace.

CP = cp -rf
MKDIR = mkdir -p
RM = rm -rf
ROOT_DIR = $(shell pwd)
XSCT = $(XILINX_VITIS)/bin/xsct
BD_NAME = maxtp
APP_POSTFIX = _test_app
SYS_POSTFIX = $(APP_POSTFIX)_system

# defaults
.DEFAULT_GOAL := workspace
TARGET ?= none
JOBS ?= 8

# valid targets
zedboard_target := 0

TARGET_LIST := $(sort $(patsubst %_target,%,$(filter %_target,$(.VARIABLES))))

# Vitis paths
VIT_SCRIPT_WS = tcl/build-vitis.tcl

# Vivado paths
VIV_DIR = $(ROOT_DIR)/../Vivado
VIV_PRJ_DIR = $(VIV_DIR)/$(TARGET)
VIV_XSA = $(VIV_PRJ_DIR)/$(BD_NAME)_wrapper.xsa

.PHONY: help
help:
	@echo 'Usage:'
	@echo ''
	@echo '  make workspace TARGET=<target> JOBS=<val>'
	@echo '    Create the Vitis workspace and add applications for specified target.'
	@echo ''
	@echo '  make all JOBS=<val>'
	@echo '    Create the Vitis workspace and add applications for all targets.'
	@echo ''
	@echo '  make clean'
	@echo '    Delete the Vitis workspace and all applications.'
	@echo ''
	@echo 'Parameters:'
	@echo ''
	@echo '  TARGET: Name of the target design, must be one of the following:'
	@$(foreach targ,$(TARGET_LIST),echo "    - $(targ)";)
	@echo ''
	@echo '  JOBS: Optional param to set number of synthesis jobs (default 8)'
	@echo ''
	@echo 'Example usage:'
	@echo '  make workspace TARGET=$(word 1,$(TARGET_LIST))'
	@echo ''

.PHONY: all
all:
	for targ in $(TARGET_LIST); do \
		$(MAKE) workspace TARGET=$$targ; \
	done

.PHONY: workspace
workspace: check_target $(VIV_XSA)
	$(XSCT) $(VIT_SCRIPT_WS) $(TARGET)

$(VIV_XSA):
	$(MAKE) -C $(VIV_DIR) xsa TARGET=$(TARGET) JOBS=$(JOBS)

.PHONY: clean
clean:
	for targ in $(TARGET_LIST); do \
		$(RM) $${targ} $${targ}$(APP_POSTFIX) $${targ}$(SYS_POSTFIX); \
	done
	$(RM) boot .metadata .Xil IDE.log .analytics updatemem*.jou updatemem*.log RemoteSystemsTempFiles embeddedsw

check_target:
ifndef $(TARGET)_target
	$(error "Please specify a TARGET. Use 'make help' to see valid targets.")
endif

