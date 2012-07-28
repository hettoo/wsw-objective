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

class Core {
    void spawnGametype() {
        objectiveSet.analyze();
        objectiveSet.parse("mapscripts/" + cVar("mapname", "", 0).getString()
                + ".cfg");
        objectiveSet.initialSpawn();
    }

    void initGametype() {
        settings.set();
    }

    bool command(cClient @client, String &cmd, String &args, int argc) {
        if (cmd == "cvarinfo") {
            GENERIC_CheatVarResponse(client, cmd, args, argc);
            return true;
        } else if (cmd == "class") {
            players.get(client).setClass(args);
            return true;
        } else if (cmd == "gamemenu") {
            players.get(client).showGameMenu();
            return true;
        } else if (cmd == "classaction1") {
            players.get(client).classAction1();
            return true;
        } else if (cmd == "classaction2") {
            players.get(client).classAction2();
            return true;
        }
        return false;
    }

    cEntity @selectSpawnPoint(cEntity @self) {
        cEntity @spawn = objectiveSet.randomSpawnPoint(self);
        if (@spawn == null)
            @spawn = GENERIC_SelectBestRandomSpawnPoint(null,
                    "info_player_deathmatch");
        return spawn;
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

    void scoreEvent(cClient @client, String &scoreEvent, String &args) {
        Player @player = players.get(client);

        if (scoreEvent == "userinfochanged")
            players.initClient(client);
        else if (scoreEvent == "disconnect")
            players.removeClient(client);
        else if (scoreEvent == "dmg" && @player != null)
            player.didDamage(args);
        else if (scoreEvent == "kill")
            players.madeKill(player, args);
    }

    void checkMatchState() {
        if (match.scoreLimitHit() || match.timeLimitHit()
                || match.suddenDeathFinished()) {
            if (match.getState() == MATCH_STATE_PLAYTIME)
                G_GetTeam(TEAM_BETA).stats.addScore(1);
            match.launchState(match.getState() + 1);
        }
    }

    void thinkRules() {
        checkMatchState();

        GENERIC_Think();

        players.think();
        objectiveSet.think();
        itemSet.think();
        bombSet.think();
        clusterbombSet.think();
        artillerySet.think();
        transporterSet.think();
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
                players.reset();
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

    String @scoreboardMessage(int maxLen) {
        return scoreboard.createMessage(maxLen);
    }

    void shutdown() {
    }
}
