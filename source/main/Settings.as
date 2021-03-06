/*
Copyright (C) 2012 Gerco van Heerdt

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

const String TITLE = "Objective";
const String VERSION = "0.1-dev";
const String AUTHOR = "^0<^7inc^2.^7hettoo^9/^7";

const int DEFAULT_ALPHA_RESPAWN_TIME = 12;
const int DEFAULT_BETA_RESPAWN_TIME = 18;

Settings settings;

class Settings {
    String configFile;

    Settings() {
        configFile = "configs/server/gametypes/" + gametype.name + ".cfg";
    }

    void setInfo() {
        gametype.title = TITLE;
        gametype.version = VERSION;
        gametype.author = AUTHOR;
    }

    void createDefaultConfig() {
        String config = "// '" + gametype.title + "' gametype"
            + " configuration file\n"
            + "// This config will be executed each time the gametype is"
            + " started\n"
            + "\n\n// map rotation\n"
            + "set g_maplist \"wdm1 wdm2 wdm3 wdm4 wdm5 wdm6 wdm7 wdm8 wdm9"
            + " wdm10 wdm11 wdm12 wdm13 wdm14 wdm15 wdm16 wdm17\""
            + " // list of maps in automatic rotation\n"
            + "set g_maprotation \"1\" // 0 = same map, 1 = in order,"
            + " 2 = random\n"
            + "\n// game settings\n"
            + "set g_scorelimit \"0\"\n"
            + "set g_timelimit \"15\"\n"
            + "set g_warmup_timelimit \"1\"\n"
            + "set g_match_extendedtime \"0\"\n"
            + "set g_allow_falldamage \"1\"\n"
            + "set g_allow_selfdamage \"1\"\n"
            + "set g_allow_teamdamage \"1\"\n"
            + "set g_allow_stun \"1\"\n"
            + "set g_teams_maxplayers \"0\"\n"
            + "set g_teams_allow_uneven \"0\"\n"
            + "set g_countdown_time \"5\"\n"
            + "set g_maxtimeouts \"3\" // -1 = unlimited\n"
            + "set g_challengers_queue \"0\"\n"
            + "\necho \"" + gametype.name + ".cfg executed\"\n";
        G_WriteFile(configFile, config);
        G_Print("Created default config file for '" + gametype.name
                + "'\n");
        G_CmdExecute("exec " + configFile + " silent");
    }

    void setGametypeSettings() {
        gametype.spawnableItemsMask = IT_ARMOR;

        if (gametype.get_isInstagib())
            gametype.spawnableItemsMask &= ~uint(G_INSTAGIB_NEGATE_ITEMMASK);

        gametype.respawnableItemsMask = gametype.spawnableItemsMask;
        gametype.dropableItemsMask = gametype.spawnableItemsMask;
        gametype.pickableItemsMask = gametype.spawnableItemsMask;

        gametype.isTeamBased = true;
        gametype.isRace = false;
        gametype.hasChallengersQueue = false;
        gametype.maxPlayersPerTeam = 0;

        gametype.ammoRespawn = 20;
        gametype.armorRespawn = 25;
        gametype.weaponRespawn = 5;
        gametype.healthRespawn = 15;
        gametype.powerupRespawn = 90;
        gametype.megahealthRespawn = 20;
        gametype.ultrahealthRespawn = 40;

        gametype.readyAnnouncementEnabled = false;
        gametype.scoreAnnouncementEnabled = false;
        gametype.countdownEnabled = false;
        gametype.mathAbortDisabled = false;
        gametype.shootingDisabled = false;
        gametype.infiniteAmmo = false;
        gametype.canForceModels = true;
        gametype.canShowMinimap = true;
        gametype.teamOnlyMinimap = true;

        gametype.spawnpointRadius = 256;

        if (gametype.get_isInstagib())
            gametype.spawnpointRadius *= 2;
    }

    void setSpawnsystem(int team, int spawnSystem, int waveTime,
            int maxPlayers) {
        gametype.setTeamSpawnsystem(team, spawnSystem, waveTime,
                maxPlayers, true);
    }

    void setSpawnsystem(int spawnSystem, int waveTime, int maxPlayers) {
        for (int team = 0; team < GS_MAX_TEAMS; team++) {
            if (team != TEAM_SPECTATOR)
                setSpawnsystem(team, spawnSystem, waveTime, maxPlayers);
        }
    }

    void setSpawnsystem(int spawnSystem) {
        setSpawnsystem(spawnSystem, 0, 0);
    }

    void setWaveSpawn(int team, int respawnTime) {
        setSpawnsystem(team, SPAWNSYSTEM_WAVES, respawnTime, 0);
    }

    void setScoreboardLayout() {
        G_ConfigString(CS_SCB_PLAYERTAB_LAYOUT,
                "%n 112 %s 52 %i 52 %l 48 %p 18 %p 18");
        G_ConfigString(CS_SCB_PLAYERTAB_TITLES, "Name Clan Score Ping C R");
    }

    void registerCommands() {
        G_RegisterCommand("class");
        G_RegisterCommand("classaction1");
        G_RegisterCommand("classaction2");
        G_RegisterCommand("gametypemenu");
        G_RegisterCommand("gametype");
    }

    void set() {
        setInfo();

        if (!G_FileExists(configFile))
            createDefaultConfig();

        setGametypeSettings();
        setSpawnsystem(SPAWNSYSTEM_INSTANT);
        setScoreboardLayout();

        registerCommands();

        G_Print("Gametype '" + gametype.title + "' initialized\n");
    }

    void setupWarmup() {
        gametype.pickableItemsMask = gametype.spawnableItemsMask;
        gametype.dropableItemsMask = gametype.spawnableItemsMask;
        GENERIC_SetUpWarmup();
    }

    void setupCountdown() {
        gametype.pickableItemsMask = 0;
        gametype.dropableItemsMask = 0;
        GENERIC_SetUpCountdown();
    }

    void setupPlaytime() {
        gametype.pickableItemsMask = gametype.spawnableItemsMask;
        gametype.dropableItemsMask = gametype.spawnableItemsMask;
        setWaveSpawn(TEAM_ALPHA, DEFAULT_ALPHA_RESPAWN_TIME);
        setWaveSpawn(TEAM_BETA, DEFAULT_BETA_RESPAWN_TIME);
        GENERIC_SetUpMatch();
    }

    void setupPostmatch() {
        gametype.pickableItemsMask = 0;
        gametype.dropableItemsMask = 0;
        GENERIC_SetUpEndMatch();
    }
}
