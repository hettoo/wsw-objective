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

const int TEAM_ASSAULT = TEAM_ALPHA;
const int TEAM_DEFENSE = TEAM_BETA;

const int PROGRESS_FINISHED = 100;

cString WTF = "???";
const int UNKNOWN = -1;

class Core {
    Settings settings;
    Scoreboard scoreboard;
    World world;

    void spawnGametype() {
        world.spawn();
    }

    void initGametype() {
        scoreboard.register(world);
        settings.set();
    }

    bool command(cClient @client, cString &cmd, cString &args, int argc) {
        if (cmd == "cvarinfo") {
            GENERIC_CheatVarResponse(client, cmd, args, argc);
            return true;
        } else if (cmd == "class") {
            world.getPlayers().get(client).setClass(args);
            return true;
        } else if (cmd == "gamemenu") {
            world.getPlayers().get(client).showGameMenu();
            return true;
        } else if (cmd == "classaction1") {
            world.getPlayers().get(client).classAction1();
            return true;
        } else if (cmd == "classaction2") {
            world.getPlayers().get(client).classAction2();
            return true;
        }
        return false;
    }

    cEntity @selectSpawnPoint(cEntity @self) {
        cEntity @spawn = world.selectSpawnPoint(self);
        if (@spawn == null)
            @spawn = GENERIC_SelectBestRandomSpawnPoint(null,
                    "info_player_deathmatch");
        return spawn;
    }

    void playerRespawn(cEntity @ent, int oldTeam, int newTeam) {
        if (oldTeam == TEAM_SPECTATOR && newTeam != TEAM_SPECTATOR)
            world.newPlayer(ent.client);
        else if (oldTeam != TEAM_SPECTATOR && newTeam == TEAM_SPECTATOR)
            world.newSpectator(ent.client);

        if (newTeam != TEAM_SPECTATOR)
            world.respawnPlayer(ent.client);
    }

    bool updateBotStatus(cEntity @self) {
        return GENERIC_UpdateBotStatus(self);
    }

    void scoreEvent(cClient @client, cString &scoreEvent, cString &args) {
        if (scoreEvent == "userinfochanged")
            world.initClient(client);
        else if (scoreEvent == "disconnect")
            world.removeClient(client);
    }

    void checkMatchState() {
        if (match.scoreLimitHit() || match.timeLimitHit()
                || match.suddenDeathFinished()) {
            if (match.getState() == MATCH_STATE_PLAYTIME)
                G_GetTeam(TEAM_DEFENSE).stats.addScore(1);
            match.launchState(match.getState() + 1);
        }
    }

    void thinkRules() {
        checkMatchState();

        GENERIC_Think();

        world.think();
    }

    void matchStateStarted() {
        switch (match.getState()) {
            case MATCH_STATE_WARMUP:
                settings.setupWarmup();
                break;
            case MATCH_STATE_COUNTDOWN:
                settings.setupCountdown();
                break;
            case MATCH_STATE_PLAYTIME:
                settings.setupPlaytime();
                break;
            case MATCH_STATE_POSTMATCH:
                settings.setupPostmatch();
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
        return scoreboard.createMessage(maxLen);
    }

    void shutdown() {
    }
}

cString @replaceSpaces(cString &string, cString replacement) {
    cString result;
    for (int i = 0; i < string.len(); i++) {
        cString character = string.substr(i, 1);
        if (character == " ")
            result += replacement;
        else
            result += character;
    }
    return result;
}

cString @replaceSpaces(cString &string) {
    return replaceSpaces(string, "_");
}
