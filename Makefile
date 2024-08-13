BIN_DIR := bin
NAME := front_office
NES_FILE := $(BIN_DIR)/$(NAME).nes

SRC_DIR := src
SRCS := \
		apu.s \
		controller.s \
		double_dabble.s \
		header.s \
		init.s \
		main.s \
		money.s \
		parameters.s \
		ppu.s
SRCS := $(SRCS:%=$(SRC_DIR)/%)

OBJ_DIR := obj
OBJS := $(SRCS:$(SRC_DIR)/%.s=$(OBJ_DIR)/%.o)

CFG_DIR := cfg
UTIL_DIR := util
TEST_DIR := test

MKDIR := mkdir -p
RM := rm -rf
DIR_UP = $(MKDIR) $(@D)

CA := ca65
CFLAGS := -g -I $(SRC_DIR)

LD := ld65
LFLAGS := -C $(CFG_DIR)/front_office.cfg -Ln $(BIN_DIR)/front_office.labels -m $(BIN_DIR)/front_office.map

FCEUX := /mnt/c/Users/zplay/Apps/FCEUX/fceux64.exe

all: $(NES_FILE)

$(NES_FILE): $(OBJS)
	$(DIR_UP)
	$(LD) $(LFLAGS) -o $(NES_FILE) $(OBJS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.s
	$(DIR_UP)
	$(CA) $(CFLAGS) -o $@ $^

clean:
	$(RM) $(OBJ_DIR)
	$(RM) $(BIN_DIR)

re:
	$(MAKE) clean
	$(MAKE) all

run: re
	-$(FCEUX) $(NES_FILE)

MAKEFLAGS += --no-print-directory
.PHONY: clean re run
.SILENT:
