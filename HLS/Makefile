# Opsero Electronic Design Inc. 2025
#
# Thin wrapper around build.py, which builds the HLS IP cores on both
# Windows and Linux (see ../build.sh ip). This make interface is kept for
# compatibility and will be REMOVED at the next version update -- please
# switch to ../build.sh.
#
# Note: on Windows use ../build.sh directly from git bash; GNU make is not
# usable there (no sh-capable make is available).

BUILD = ./build.sh

.PHONY: help all ip clean
help:
	@echo 'Usage:'
	@echo ''
	@echo '  make all'
	@echo '    Generate all HLS IP cores (wraps: ../build.sh ip --target all).'
	@echo ''
	@echo '  make clean'
	@echo '    Delete generated HLS projects (wraps: ../build.sh clean --stage ip --target all).'
	@echo ''
	@echo 'DEPRECATED: drive builds with ../build.sh instead (works on Windows too).'

all ip:
	cd .. && $(BUILD) ip --target all

clean:
	cd .. && $(BUILD) clean --stage ip --target all
