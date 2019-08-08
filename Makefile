# -*- mode: BSDmakefile; tab-width: 8; indent-tabs-mode: nil -*-

OPENSSL = openssl

ifndef PYTHON
PYTHON := python3
endif

ifeq ($(MAKECMDGOALS),client-cert)

ifndef CN
$(error   "Please add option.. CN=<name> to run target client-cert")
endif
rootdir = $(realpath .)

ifneq ("$(wildcard $(rootdir)/testca/cacert.pem)","")
$(info  Will use ca cert $(rootdir)/testca/cacert.pem to sign the client cert)
else
$(error "Please run make to generate ca certificate before running make client-cert")
endif

CN := $(shell hostname)

endif

ifndef CLIENT_ALT_NAME
CLIENT_ALT_NAME := $(shell hostname)
endif

ifndef SERVER_ALT_NAME
SERVER_ALT_NAME := $(shell hostname)
endif

ifndef NUMBER_OF_PRIVATE_KEY_BITS
NUMBER_OF_PRIVATE_KEY_BITS := 2048
endif

ifndef DAYS_OF_VALIDITY
DAYS_OF_VALIDITY := 3650
endif

ifndef ECC_CURVE
ECC_CURVE := "prime256v1"
endif

ifndef USE_ECC
USE_ECC := false
endif

ifeq ($(USE_ECC),true)
ECC_FLAGS := --use-ecc --ecc-curve $(ECC_CURVE)
endif

PASS := ""
ifdef PASSWORD
PASS = "$(PASSWORD)"
endif

all: regen verify

clean:
	$(PYTHON) profile.py clean

gen:
	$(PYTHON) profile.py generate --password $(PASS) \
	--common-name $(CN) \
	--client-alt-name $(CLIENT_ALT_NAME) \
	--server-alt-name $(SERVER_ALT_NAME) \
	--days-of-validity $(DAYS_OF_VALIDITY) \
	--key-bits $(NUMBER_OF_PRIVATE_KEY_BITS) $(ECC_FLAGS)

regen:
	$(PYTHON) profile.py regenerate --password $(PASS) \
	--common-name $(CN) \
	--client-alt-name $(CLIENT_ALT_NAME) \
	--server-alt-name $(SERVER_ALT_NAME) \
	--days-of-validity $(DAYS_OF_VALIDITY) \
	--key-bits $(NUMBER_OF_PRIVATE_KEY_BITS) $(ECC_FLAGS)

client-cert:
	$(PYTHON) profile.py client --password $(PASS) \
	--common-name $(CN) \
	--client-alt-name $(CLIENT_ALT_NAME) \
	--days-of-validity $(DAYS_OF_VALIDITY) \
	--key-bits $(NUMBER_OF_PRIVATE_KEY_BITS) $(ECC_FLAGS)

info:
	$(PYTHON) profile.py info

verify:
	$(PYTHON) profile.py verify

help:
	$(PYTHON) profile.py --help
