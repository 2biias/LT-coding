# Define the path to the project config file
DEFINES+=PROJECT_CONF_H=\"project-conf.h\"

CONTIKI_PROJECT = $(notdir $(CURDIR))
all: $(CONTIKI_PROJECT)

CONTIKI = /home/vagrant/contiki-ng

PLATFORMS_EXCLUDE = nrf52dk

# Treat warnings as errors
WERROR := 1 		
CFLAGS += -O3
CFLAGS += -std=gnu11

#use this to enable TSCH: MAKE_MAC = MAKE_MAC_TSCH
MAKE_MAC ?= MAKE_MAC_CSMA
MAKE_NET = MAKE_NET_NULLNET
include $(CONTIKI)/Makefile.include