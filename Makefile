NAME := front_office.nes

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

BIN_DIR := bin
MKDIR_BIN := mkdir -o $(BIN_DIR)
NES_FILE := $(BIN_DIR)/$(NAME).nes

CFG_DIR := cfg
UTIL_DIR := util

CA := ca65
CFLAGS := -g #-I $(LIB_DIR)

LD := ld65
LFLAGS := -C $(CFG_DIR)/front_office.cfg -Ln $(BIN_DIR)/front_office.labels -m $(BIN_DIR)/front_office.map

RM := rm -rf
MAKEFLAGS += --no-print-directory
MKDIR := mkdir -p
DIR_UP = $(MKDIR) $(@D)

FCEUX := /mnt/c/Users/zplay/Apps/FCEUX/fceux64.exe

all: $(NAME)

$(NAME): $(OBJS)
	$(MKDIR) $(BIN_DIR)
	$(LD) $(LFLAGS) -o $(NES_FILE) $(OBJS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.s
	$(DIR_UP)
	$(CA) $(CFLAGS) -o $@ $<

clean:
	$(RM) $(OBJ_DIR)
	$(RM) $(BIN_DIR)

re:
	$(MAKE) clean
	$(MAKE) all

run: re
	-$(FCEUX) $(NES_FILE)

.PHONY: clean re run
.SILENT:
