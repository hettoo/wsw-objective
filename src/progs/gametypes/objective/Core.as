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

class Core {
    cString configFile;

    Core() {
        configFile = "configs/server/gametypes/" + gametype.getName() + ".cfg";
    }

    void spawnGametype() {
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
        gametype.spawnableItemsMask = (IT_WEAPON | IT_AMMO | IT_ARMOR
                | IT_POWERUP | IT_HEALTH);

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

        if ( gametype.isInstagib() )
            gametype.spawnpointRadius *= 2;
    }

    void setSpawnSystem() {
        for (int team = 0; team < GS_MAX_TEAMS; team++) {
            if (team != TEAM_SPECTATOR)
                gametype.setTeamSpawnsystem(team, SPAWNSYSTEM_INSTANT, 0, 0,
                        false);
        }
    }

    void setScoreboardLayout() {
        G_ConfigString(CS_SCB_PLAYERTAB_LAYOUT,
                "%n 112 %s 52 %i 52 %l 48 %p 18 %p 18");
        G_ConfigString(CS_SCB_PLAYERTAB_TITLES, "Name Clan Score Ping C R");
    }

    void registerCommands() {
        G_RegisterCommand("drop");
        G_RegisterCommand("gametype");
    }

    void initGametype() {
        setGametypeInfo();

        if (!G_FileExists(configFile))
            createDefaultConfig();

        setGametypeSettings();
        setSpawnSystem();
        setScoreboardLayout();

        registerCommands();

        G_Print("Gametype '" + gametype.getTitle() + "' initialized\n");
    }

    bool command(cClient @client, cString &cmd, cString &args, int argc) {
        return true;
    }

    cEntity @selectSpawnPoint(cEntity @self) {
        return null;
    }

    void playerRespawn(cEntity @ent, int oldTeam, int newTeam) {
    }

    bool updateBotStatus(cEntity @self) {
        return true;
    }

    void scoreEvent(cClient @client, cString &scoreEvent, cString &args) {
    }

    void thinkRules() {
    }

    void matchStateStarted() {
    }

    bool matchStateFinished(int newMatchState) {
        return true;
    }

    cString @scoreboardMessage(int maxLen) {
        return "";
    }

    void shutdown() {
    }
}
