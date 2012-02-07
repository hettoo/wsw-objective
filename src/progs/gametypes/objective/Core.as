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

const cString TITLE = "Objective";
const cString VERSION = "0.1-dev";
const cString AUTHOR = "^0<].^7h^2e^9tt^2o^7o^0.[>^7";

const int DEFAULT_RESPAWN_TIME = 12;

const cString WTF = "???";

class Core {
    Players players;
    Objectives objectives;

    cString configFile;

    Core() {
        configFile = "configs/server/gametypes/" + gametype.getName() + ".cfg";
    }

    void spawnGametype() {
        objectives.analyze();
        objectives.parse("mapscripts/" + cVar("mapname", "", 0).getString()
                + ".obj");
    }

    void setGametypeInfo() {
        gametype.setTitle(TITLE);
        gametype.setVersion(VERSION);
        gametype.setAuthor(AUTHOR);
    }

    void createDefaultConfig() {
        cString config = "// '" + gametype.getTitle() + "' gametype"
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
            + "\necho \"" + gametype.getName() + ".cfg executed\"\n";
        G_WriteFile(configFile, config);
        G_Print("Created default config file for '" + gametype.getName() + "'\n");
        G_CmdExecute("exec " + configFile + " silent");
    }

    void setGametypeSettings() {
        gametype.spawnableItemsMask = (IT_ARMOR | IT_POWERUP | IT_HEALTH);

        if (gametype.isInstagib())
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
        gametype.canShowMinimap = false;
        gametype.teamOnlyMinimap = false;

        gametype.spawnpointRadius = 256;

        if (gametype.isInstagib())
            gametype.spawnpointRadius *= 2;
    }

    void setSpawnSystem(int spawnSystem, int waveTime, int maxPlayers) {
        for (int team = 0; team < GS_MAX_TEAMS; team++) {
            if (team != TEAM_SPECTATOR)
                gametype.setTeamSpawnsystem(team, spawnSystem, waveTime,
                        maxPlayers, false);
        }
    }

    void setSpawnSystem(int spawnSystem) {
        setSpawnSystem(spawnSystem, 0, 0);
    }

    void setScoreboardLayout() {
        G_ConfigString(CS_SCB_PLAYERTAB_LAYOUT,
                "%n 112 %s 52 %i 52 %l 48 %p 18 %p 18");
        G_ConfigString(CS_SCB_PLAYERTAB_TITLES, "Name Clan Score Ping C R");
    }

    void registerCommands() {
        G_RegisterCommand("class");
        G_RegisterCommand("gamemenu");
        G_RegisterCommand("gametype");
    }

    void initGametype() {
        setGametypeInfo();

        if (!G_FileExists(configFile))
            createDefaultConfig();

        setGametypeSettings();
        setSpawnSystem(SPAWNSYSTEM_INSTANT);
        setScoreboardLayout();

        registerCommands();

        G_Print("Gametype '" + gametype.getTitle() + "' initialized\n");
    }

    bool command(cClient @client, cString &cmd, cString &args, int argc) {
        if (cmd == "cvarinfo") {
            GENERIC_CheatVarResponse(client, "cvarinfo", args, argc);
            return true;
        } else if (cmd == "class") {
            players.get(client).setClass(args);
            return true;
        } else if (cmd == "gamemenu") {
            players.get(client).showGameMenu();
        }
        return false;
    }

    cEntity @selectSpawnPoint(cEntity @self) {
        return GENERIC_SelectBestRandomSpawnPoint(null, "info_player_deathmatch");
    }

    void playerRespawn(cEntity @ent, int oldTeam, int newTeam) {
        if (oldTeam == TEAM_SPECTATOR && newTeam != TEAM_SPECTATOR)
            players.newPlayer(ent.client);
        else if (oldTeam != TEAM_SPECTATOR && newTeam == TEAM_SPECTATOR)
            players.newSpectator(ent.client);

        if (newTeam != TEAM_SPECTATOR)
            players.respawnPlayer(ent.client);
    }

    bool updateBotStatus(cEntity @self) {
        return GENERIC_UpdateBotStatus(self);
    }

    void scoreEvent(cClient @client, cString &scoreEvent, cString &args) {
        if (scoreEvent == "userinfochanged")
            players.initClient(client);
    }

    void checkMatchState() {
        if (match.scoreLimitHit() || match.timeLimitHit() || match.suddenDeathFinished())
            match.launchState(match.getState() + 1);

        if (match.getState() >= MATCH_STATE_POSTMATCH)
            return;
    }

    void thinkRules() {
        checkMatchState();

        GENERIC_Think();
    }

    void setWaveSpawn(int respawnTime) {
        setSpawnSystem(SPAWNSYSTEM_WAVES, respawnTime, 0);
    }

    void matchStateStarted() {
        switch (match.getState()) {
            case MATCH_STATE_WARMUP:
                gametype.pickableItemsMask = gametype.spawnableItemsMask;
                gametype.dropableItemsMask = gametype.spawnableItemsMask;
                GENERIC_SetUpWarmup();
                CreateSpawnIndicators("info_player_deathmatch", TEAM_BETA);
                break;
            case MATCH_STATE_COUNTDOWN:
                gametype.pickableItemsMask = 0;
                gametype.dropableItemsMask = 0;
                GENERIC_SetUpCountdown();
                DeleteSpawnIndicators();
                break;
            case MATCH_STATE_PLAYTIME:
                gametype.pickableItemsMask = gametype.spawnableItemsMask;
                gametype.dropableItemsMask = gametype.spawnableItemsMask;
                setWaveSpawn(DEFAULT_RESPAWN_TIME);
                GENERIC_SetUpMatch();
                break;
            case MATCH_STATE_POSTMATCH:
                gametype.pickableItemsMask = 0;
                gametype.dropableItemsMask = 0;
                GENERIC_SetUpEndMatch();
                break;
        }
    }

    bool matchStateFinished(int newMatchState) {
        if (match.getState() <= MATCH_STATE_WARMUP
                && newMatchState > MATCH_STATE_WARMUP
                && newMatchState < MATCH_STATE_POSTMATCH)
            match.startAutorecord();

        if (match.getState() == MATCH_STATE_POSTMATCH)
            match.stopAutorecord();

        return true;
    }

    cString @scoreboardMessage(int maxLen) {
        cString msg = "";

        for (int i = TEAM_ALPHA; i < GS_MAX_TEAMS; i++) {
            cTeam @team = @G_GetTeam(i);

            cString entry = "&t " + i + " " + team.stats.score + " " + team.ping
                + " ";
            if (msg.len() + entry.len() < maxLen)
                msg += entry;

            for (int j = 0; @team.ent(j) != null; j++) {
                cEntity @ent = team.ent(j);
                int classIcon = 0;
                int readyIcon = 0;

                //if (ent.client.isReady())
                //    readyIcon = prcYesIcon;

                int playerID = (ent.isGhosting()
                        && (match.getState() == MATCH_STATE_PLAYTIME))
                    ? -(ent.playerNum() + 1) : ent.playerNum();

                entry = "&p " + playerID + " " + ent.client.getClanName() + " "
                    + ent.client.stats.score + " " + ent.client.ping + " "
                    + classIcon + " " + readyIcon + " ";

                if (msg.len() + entry.len() < maxLen)
                    msg += entry;
            }
        }

        return msg;
    }

    void shutdown() {
    }
}
