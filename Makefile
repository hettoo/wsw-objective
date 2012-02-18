# You may want to edit these, either here or from the commandline using
# VARIABLE=value
WSW_DIR = ~/.warsow-0.6
EXECUTABLE = wsw-server
MOD = promod

NAME = objective
SERVER_CMD = $(EXECUTABLE) +set fs_game $(MOD) +set g_gametype $(NAME)
THIS = Makefile
GT_DIR = src
GT_CORE_DIR = $(GT_DIR)/progs
TMP_DIR = tmp
BASE_MOD = basewsw
CONFIG_DIR = configs/server/gametypes
CORE_FILES = $(shell find $(GT_CORE_DIR))
DATA_FILES = $(shell find $(GT_DIR)/ | grep -v $(GT_CORE_DIR))
SETTINGS_FILE = $(GT_CORE_DIR)/gametypes/$(NAME)/Settings.as
EVERY_PK3 = $(NAME)-*.pk3
CFG = $(NAME).cfg

VERSION = $(shell grep VERSION $(SETTINGS_FILE) \
		  | head -n1 | sed 's/.*"\(.*\)".*/\1/')
VERSION_WORD = $(subst .,_,$(VERSION))
CORE_PK3 = $(NAME)-$(VERSION_WORD).pk3
DATA_PK3 = $(NAME)-data-$(VERSION_WORD)_pure.pk3

all: $(CORE_PK3) $(DATA_PK3)

$(CORE_PK3): $(CORE_FILES) $(THIS)
	rm -rf $(TMP_DIR)
	mkdir $(TMP_DIR)
	rm -f $(CORE_PK3)
	cp -r $(GT_CORE_DIR) $(TMP_DIR)/
	cd $(TMP_DIR); zip ../$(CORE_PK3) -r -xi *
	rm -r $(TMP_DIR)

$(DATA_PK3): $(DATA_FILES) $(THIS)
	rm -rf $(TMP_DIR)
	mkdir $(TMP_DIR)
	rm -f $(DATA_PK3)
	cp -r $(shell find $(GT_DIR) -mindepth 1 -maxdepth 1 | grep -v $(GT_CORE_DIR)) $(TMP_DIR)/
	cd $(TMP_DIR); zip ../$(DATA_PK3) -r -xi *
	rm -r $(TMP_DIR)

local: all
	cp $(CORE_PK3) $(WSW_DIR)/$(BASE_MOD)/
	cp $(DATA_PK3) $(WSW_DIR)/$(BASE_MOD)/

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

.PHONY: all local production clean destroy restart dev
