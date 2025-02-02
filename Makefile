SHELL := /bin/bash

# Rez variables, setting these to sensible values if we are not building from rez
REZ_BUILD_PROJECT_VERSION ?= NOT_SET
REZ_BUILD_INSTALL_PATH ?= /home/minwoo/packages/oiio
REZ_BUILD_SOURCE_PATH ?= $(shell dirname $(lastword $(abspath $(MAKEFILE_LIST))))
BUILD_ROOT := $(REZ_BUILD_SOURCE_PATH)/build
REZ_BUILD_PATH ?= $(BUILD_ROOT)
REZ_PYTHON_VERSION ?= 3.9.16

# Build time locations
SOURCE_DIR := $(BUILD_ROOT)/oiio/
BUILD_TYPE = Release
BUILD_DIR = ${REZ_BUILD_PATH}/BUILD/$(BUILD_TYPE)

# Source
REPOSITORY_URL := https://github.com/OpenImageIO/oiio.git
TAG ?= v2.5.15.0

# Installation prefix
PREFIX ?= ${REZ_BUILD_INSTALL_PATH}

# Python version to find for bindings
PYTHON_VERSION ?= $(REZ_PYTHON_VERSION)

# CMake Arguments
CMAKE_ARGS := -DCMAKE_INSTALL_PREFIX=$(PREFIX) \
	-DCMAKE_BUILD_TYPE=$(BUILD_TYPE) \
	-DCMAKE_SKIP_RPATH=ON \
	-DUSE_PYTHON=ON \
	-DPYTHON_VERSION=$(PYTHON_VERSION) \
	-DCMAKE_CXX_STANDARD=17 \
	-DOIIO_BUILD_TESTS=FALSE \
	# -DPNG_INCLUDE_DIR=/cocoa/inhouse/tool/rez-packages/png/1.6.44/platform-linux/arch-x86_64/include \
	# -DPNG_LIBRARY=/cocoa/inhouse/tool/rez-packages/png/1.6.44/platform-linux/arch-x86_64/lib64/

# Warn about building master if no tag is provided
ifeq "$(TAG)" "vNOT_SET"
$(warning "No tag was specified, main will be built. You can specify a tag: TAG=v2.1.0")
TAG:=master
endif

.PHONY: build install test clean
.DEFAULT: build

$(BUILD_DIR): # Prepare build directories
	mkdir -p $(BUILD_ROOT)
	mkdir -p $(BUILD_DIR)

$(SOURCE_DIR): | $(BUILD_DIR) # Clone the repository
	cd $(BUILD_ROOT) && git clone $(REPOSITORY_URL)

# Build
build: $(SOURCE_DIR) # Checkout the correct tag and build
	cd $(SOURCE_DIR) && git fetch --all && git checkout $(TAG)
	cd $(BUILD_DIR) && cmake $(CMAKE_ARGS) $(SOURCE_DIR) && make

install: build
	mkdir -p $(REZ_BUILD_INSTALL_PATH)
	cd $(BUILD_DIR) && make install

test: build # Run the tests in the build
	$(MAKE) -C $(BUILD_DIR)/BUILD/Release/ test

clean:
	rm -rf $(BUILD_ROOT)