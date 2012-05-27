# You may want to edit these, either here or from the commandline using
# VARIABLE=value
WSW_DIR = ~/.warsow-0.6
EXECUTABLE = wsw-server
MOD = promod

NAME = objective
SERVER_CMD = $(EXECUTABLE) +set fs_game $(MOD) +set g_gametype $(NAME)
THIS = Makefile
GT_DIR = src
TMP_DIR = tmp
BASE_MOD = basewsw
CONFIG_DIR = configs/server/gametypes
FILES = $(shell find $(GT_DIR))
SETTINGS_FILE = $(GT_DIR)/progs/gametypes/$(NAME)/Settings.as
EVERY_PK3 = $(NAME)-*.pk3
CFG = $(NAME).cfg

VERSION = $(shell grep VERSION $(SETTINGS_FILE) \
		  | head -n1 | sed 's/.*"\(.*\)".*/\1/')
VERSION_WORD = $(subst .,_,$(VERSION))
PK3 = $(NAME)-$(VERSION_WORD)-pure.pk3

all: dist

dist: $(PK3)

$(PK3): $(FILES) $(THIS)
	rm -rf $(TMP_DIR)
	mkdir $(TMP_DIR)
	rm -f $(PK3)
	cp -r $(GT_DIR)/* $(TMP_DIR)/
	cd $(TMP_DIR); zip ../$(PK3) -r -xi *
	rm -r $(TMP_DIR)

local: all
	cp $(PK3) $(WSW_DIR)/$(BASE_MOD)/

production: local
	$(SERVER_CMD)

productionloop: local
	while true; do $(SERVER_CMD); done

clean:
	rm -f $(EVERY_PK3)

destroy:
	rm -f $(WSW_DIR)/$(BASE_MOD)/$(EVERY_PK3)
	rm -f $(WSW_DIR)/$(BASE_MOD)/$(CONFIG_DIR)/$(CFG)
	rm -f $(WSW_DIR)/$(MOD)/$(CONFIG_DIR)/$(CFG)

restart: destroy local

dev: restart
	$(SERVER_CMD)

.PHONY: all dist local production clean destroy restart dev
