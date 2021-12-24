#!/usr/bin/make -f

PACKAGES_SIMTEST=$(shell go list ./... | grep '/simulation')
VERSION := $(shell echo $(shell git describe --tags) | sed 's/^v//')
COMMIT := $(shell git log -1 --format='%H')
LEDGER_ENABLED ?= true
SDK_PACK := $(shell go list -m github.com/fincor/cusp-sdk | sed  's/ /\@/g')

export GO111MODULE = on

# process build tags

build_tags = netgo


ifeq ($(WITH_CLEVELDB),yes)
  build_tags += gcc
endif
build_tags += $(BUILD_TAGS)
build_tags := $(strip $(build_tags))

whitespace :=
whitespace += $(whitespace)
comma := ,
build_tags_comma_sep := $(subst $(whitespace),$(comma),$(build_tags))

# process linker flags

ldflags = -X github.com/fincor/cusp-sdk/version.Name=cusp \
		  -X github.com/fincor/cusp-sdk/version.ServerName=cuspd \
		  -X github.com/fincor/cusp-sdk/version.ClientName=cuspcli \
		  -X github.com/fincor/cusp-sdk/version.Version=$(VERSION) \
		  -X github.com/fincor/cusp-sdk/version.Commit=$(COMMIT) \
		  -X "github.com/fincor/cusp-sdk/version.BuildTags=$(build_tags_comma_sep)"

ifeq ($(WITH_CLEVELDB),yes)
  ldflags += -X github.com/fincor/cusp-sdk/types.DBBackend=cleveldb
endif
ldflags += $(LDFLAGS)
ldflags := $(strip $(ldflags))

BUILD_FLAGS := -tags "$(build_tags)" -ldflags '$(ldflags)'

# The below include contains the tools target.
# include contrib/devtools/Makefile

all: install lint check

build: go.sum
ifeq ($(OS),Windows_NT)
	go build -mod=readonly $(BUILD_FLAGS) -o build/cuspd.exe ./cmd/cuspd
	go build -mod=readonly $(BUILD_FLAGS) -o build/cuspcli.exe ./cmd/cuspcli
else
	go build -mod=readonly $(BUILD_FLAGS) -o build/cuspd ./cmd/cuspd
	go build -mod=readonly $(BUILD_FLAGS) -o build/cuspcli ./cmd/cuspcli
endif

build-linux: go.sum
	LEDGER_ENABLED=false GOOS=linux GOARCH=amd64 $(MAKE) build

install: go.sum
	go install -mod=readonly $(BUILD_FLAGS) ./cmd/cuspd
	go install -mod=readonly $(BUILD_FLAGS) ./cmd/cuspcli

########################################

# include simulations
# include sims.mk

.PHONY: all build-linux install install-debug \
	go-mod-cache draw-deps clean build \
	setup-transactions setup-contract-tests-data start-cusp run-lcd-contract-tests contract-tests \
	test test-all test-build test-cover test-unit test-race