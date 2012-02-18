# You may want to edit these, either here or from the commandline using
# VARIABLE=value
WSW_DIR = ~/.warsow-0.6
EXECUTABLE = wsw-server
MOD = promod

SERVER_CMD = $(EXECUTABLE) +set fs_game $(MOD) +set g_gametype objective \

THIS = Makefile
GT_DIR = src
TMP_DIR = tmp
BASE_MOD = basewsw
CONFIG_DIR = configs/server/gametypes
SETTINGS_FILE = progs/gametypes/objective/Settings.as
EVERY_PK3 = objective-*.pk3
CFG = objective.cfg

VERSION = $(shell grep VERSION $(GT_DIR)/$(SETTINGS_FILE) \
		  | head -n1 | sed 's/.*"\(.*\)".*/\1/')
VERSION_WORD = $(subst .,_,$(VERSION))
GT_PK3 = objective-$(VERSION_WORD)_pure.pk3

all: $(GT_PK3)

$(GT_PK3): $(shell find $(GT_DIR)/) $(THIS)
	rm -rf $(TMP_DIR)
	mkdir $(TMP_DIR)
	rm -f *.pk3
	cp -r $(GT_DIR)/* $(TMP_DIR)/
	cd $(TMP_DIR); zip ../$(GT_PK3) -r -xi *
	rm -r $(TMP_DIR)

local: $(GT_PK3)
	cp $(GT_PK3) $(WSW_DIR)/$(BASE_MOD)/

production: local
	$(SERVER_CMD)

productionloop: local
	while true; do $(SERVER_CMD); done

clean:
	rm -f *.pk3

destroy:
	rm -f $(WSW_DIR)/$(BASE_MOD)/$(EVERY_PK3)
	rm -f $(WSW_DIR)/$(BASE_MOD)/$(CONFIG_DIR)/$(CFG)
	rm -f $(WSW_DIR)/$(MOD)/$(CONFIG_DIR)/$(CFG)

restart: destroy local

dev: restart
	$(SERVER_CMD)

.PHONY: all local production clean destroy restart dev
