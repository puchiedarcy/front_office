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

BIN_DIR := bin

OBJ_DIR := obj
OBJS := $(SRCS:$(SRC_DIR)/%.s=$(OBJ_DIR)/%.o)
DEPS := $(SRCS:$(SRC_DIR)/%.s=$(OBJ_DIR)/%.d)

-include $(DEPS)

TEST_OBJS := $(SRCS:$(SRC_DIR)/%.s=$(OBJ_DIR)/test_%.o)
TEST_PRGS := $(SRCS:$(SRC_DIR)/%.s=$(BIN_DIR)/test_%.prg)
TEST_PRGS := $(filter-out %header.prg %main.prg %parameters.prg, $(TEST_PRGS))

MKDIR_BIN := mkdir -o $(BIN_DIR)
NES_FILE := $(BIN_DIR)/$(NAME).nes

CFG_DIR := cfg

UTIL_DIR := util

TEST_DIR := test

CA := ca65
CFLAGS = -g -I $(SRC_DIR) --create-dep $(subst .o,.d,$@)
CFLAGS_TEST := -t sim6502

LD := ld65
LFLAGS := -C $(CFG_DIR)/front_office.cfg -Ln $(BIN_DIR)/front_office.labels -m $(BIN_DIR)/front_office.map
LFLAGS_TEST := -C $(CFG_DIR)/sim6502_with_oam.cfg sim6502.lib

RM := rm -rf
MAKEFLAGS += --no-print-directory
MKDIR := mkdir -p
DIR_UP = $(MKDIR) $(@D)

FCEUX := /mnt/c/Users/zplay/Apps/FCEUX/fceux64.exe

SIM := sim65
SIM_FLAGS := # -c -v

all: $(NAME)

$(NAME): $(OBJS)
	$(MKDIR) $(BIN_DIR)
	$(LD) $(LFLAGS) -o $(NES_FILE) $(OBJS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.s
	$(DIR_UP)
	$(CA) $(CFLAGS) -o $@ $^

test: $(TEST_PRGS)
	$(MKDIR) $(BIN_DIR)

$(BIN_DIR)/test_main.prg:

$(BIN_DIR)/test_%.prg: $(OBJ_DIR)/test_%.o $(OBJ_DIR)/%.o $(OBJ_DIR)/parameters.o
	$(MKDIR) $(BIN_DIR)
	$(LD) $(LFLAGS_TEST) -o $@ $^
	$(SIM) $(SIM_FLAGS) $@

$(OBJ_DIR)/test_%.o: $(TEST_DIR)/%.s
	$(DIR_UP)
	$(CA) $(CFLAGS) $(CFLAGS_TEST) -o $@ $^

clean:
	$(RM) $(OBJ_DIR)
	$(RM) $(BIN_DIR)

re:
	$(MAKE) clean
	$(MAKE) test
	$(MAKE) all

run: re
	-$(FCEUX) $(NES_FILE)

.PHONY: clean re run
.SILENT:
