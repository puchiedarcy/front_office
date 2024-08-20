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
REPORT_CARD_MAKER := $(UTIL_DIR)/report_card_maker.sh
REPORT_CARD := $(BIN_DIR)/$(NAME)_test_report_card.json

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

test: $(REPORT_CARD)

$(REPORT_CARD): $(TEST_RESULTS)
	$(REPORT_CARD_MAKER) $(BIN_DIR) $@ $(TEST_DIR)

$(BIN_DIR)/test_%.results: $(BIN_DIR)/test_%.prg
	-$(SIM) $(SFLAGS) $^ $(SOUT)

$(BIN_DIR)/test_money.prg: $(OBJ_DIR)/double_dabble.o $(OBJ_DIR)/ppu.o

$(BIN_DIR)/test_%.prg: $(OBJ_DIR)/test_%.o $(OBJ_DIR)/%.o $(OBJ_DIR)/parameters.o
	$(DIR_UP)
	$(LD) $(LFLAGS_TEST) $@ $^

$(OBJ_DIR)/test_%.o: $(TEST_DIR)/%.s
	$(DIR_UP)
	$(CA) $(CFLAGS) $@ $^

PERF_DIR := perf
PERF_DD_NUM_BINARY_BYTES := 01 02 03 04 05 06 07 08 09 0A 0B

define perf_double_dabble_template =
PERF_RESULTS += $$(BIN_DIR)/perf_double_dabble_$(1).results

$$(BIN_DIR)/perf_double_dabble_$(1).results: $$(BIN_DIR)/perf_double_dabble_$(1).prg
	-$$(SIM) $$(SFLAGS) $$^ $$(SOUT)

$$(BIN_DIR)/perf_double_dabble_$(1).prg: $$(OBJ_DIR)/perf_double_dabble_$(1).o $$(OBJ_DIR)/double_dabble.o
	$$(DIR_UP)
	$$(LD) $$(LFLAGS_TEST) $$@ $$^

$$(OBJ_DIR)/perf_double_dabble_$(1).o: $$(PERF_DIR)/double_dabble.s
	$$(DIR_UP)
	$$(CA) $$(CFLAGS) $$@ $$^ -D NUM_BINARY_BYTES=0x$(1)
endef

$(foreach num_bytes,$(PERF_DD_NUM_BINARY_BYTES),$(eval $(call perf_double_dabble_template,$(num_bytes))))

PERF_REPORT_CARD := $(BIN_DIR)/$(NAME)_perf_report_card.json

perf: $(PERF_REPORT_CARD)

$(PERF_REPORT_CARD): $(PERF_RESULTS)
	$(REPORT_CARD_MAKER) $(BIN_DIR) $@ $(PERF_DIR)

clean:
	$(RM) $(OBJ_DIR)
	$(RM) $(BIN_DIR)

re:
	$(MAKE) clean
	$(MAKE) test
	$(MAKE) all

run: all
	-$(FCEUX) $(NES_FILE)

MAKEFLAGS += --no-print-directory
.PHONY: all clean re run test
.SILENT:
