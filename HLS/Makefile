# Opsero Electronic Design Inc. 2024

RM = rm -rf
HLS = vitis_hls

eth_traffic_gen_target := 0

TARGET_LIST := $(patsubst %_target,%,$(filter %_target,$(.VARIABLES)))

.PHONY: help
help:
	@echo 'Usage:'
	@echo ''
	@echo '  make ip TARGET=<val>'
	@echo '    Generate target IP'
	@echo ''
	@echo '  make all'
	@echo '    Generate all IP'
	@echo ''
	@echo '  make clean'
	@echo '    Delete all IP output products'
	@echo ''
	@echo 'Parameters:'
	@echo ''
	@echo '  TARGET: Name of the target IP, must be one of the following:'
	@$(foreach targ,$(sort $(TARGET_LIST)),echo "    - $(targ)";)
	@echo ''
	@echo 'Example usage:'
	@echo '  make ip TARGET=$(word 1,$(TARGET_LIST))'
	@echo ''

.PHONY: all
all: 
	for targ in $(TARGET_LIST); do \
		$(MAKE) ip TARGET=$${targ}; \
	done

ip:  
	cd $(TARGET) && $(HLS) -f $(TARGET).tcl

.PHONY: clean
clean:
	$(RM) *.prj *.log

