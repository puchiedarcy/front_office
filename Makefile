BIN_DIR := bin
NAME := front_office
NES_FILE := $(BIN_DIR)/$(NAME).nes

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
TESTS := $(filter-out header.s main.s parameters.s, $(SRCS))

SRC_DIR := src
SRCS := $(SRCS:%=$(SRC_DIR)/%)

TEST_DIR := test
TEST_RESULTS := $(TESTS:%.s=$(BIN_DIR)/test_%.results)

OBJ_DIR := obj
OBJS := $(SRCS:$(SRC_DIR)/%.s=$(OBJ_DIR)/%.o)

CFG_DIR := cfg
CFG := $(CFG_DIR)/$(NAME).cfg

UTIL_DIR := util
LABEL_MAKER := $(UTIL_DIR)/label_maker.sh
LABELS := $(BIN_DIR)/$(NAME).labels
MAP_MAKER := $(UTIL_DIR)/map_maker.sh
MAP := $(BIN_DIR)/$(NAME).map
SPACE_USED := $(BIN_DIR)/$(NAME)_space_used.json

MKDIR := mkdir -p
RM := rm -rf
DIR_UP = $(MKDIR) $(@D)

CA := ca65
CFLAGS := -g -I $(SRC_DIR) -o

LD := ld65
LFLAGS := -C $(CFG) -Ln $(LABELS) -m $(MAP) -o
LFLAGS_TEST := -C $(CFG_DIR)/sim6502.cfg sim6502.lib -o

SIM := sim65
SFLAGS := -c -v
SOUT = > $@ 2> $@

FCEUX := /mnt/c/Users/zplay/Apps/FCEUX/fceux64.exe

all: $(NES_FILE)

$(NES_FILE): $(OBJS)
	$(DIR_UP)
	$(LD) $(LFLAGS) $(NES_FILE) $(OBJS)
	$(LABEL_MAKER) $(LABELS) $(BIN_DIR)
	$(MAP_MAKER) $(MAP) $(CFG) $(SPACE_USED)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.s
	$(DIR_UP)
	$(CA) $(CFLAGS) $@ $^

test: $(TEST_RESULTS)

$(BIN_DIR)/test_%.results: $(BIN_DIR)/test_%.prg
	$(SIM) $(SFLAGS) $^ $(SOUT)

$(BIN_DIR)/test_%.prg: $(OBJ_DIR)/test_%.o $(OBJ_DIR)/%.o $(OBJ_DIR)/parameters.o
	$(DIR_UP)
	$(LD) $(LFLAGS_TEST) $@ $^

$(OBJ_DIR)/test_%.o: $(TEST_DIR)/%.s
	$(DIR_UP)
	$(CA) $(CFLAGS) $@ $^

clean:
	$(RM) $(OBJ_DIR)
	$(RM) $(BIN_DIR)

re:
	$(MAKE) clean
	$(MAKE) test
	$(MAKE) all

run: re
	-$(FCEUX) $(NES_FILE)



MAKEFLAGS += --no-print-directory
.PHONY: all clean re run test
.SILENT:
