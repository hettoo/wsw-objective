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

Main main;

cEntity @camera;
cEntity @surface;

Vec3 angles(45, 45, 45);

class Main {
    Parser @parser;

    void spawnGametype() {
        objectiveSet.analyze();
        @parser = Parser(StandardProcessor());
        parse(Cvar("mapname", "", 0).get_string());

        for (int i = 0; @G_GetEntity(i) != null; i++) {
            cEntity @ent = G_GetEntity(i);
            String targetname = ent.get_targetname();
            if (targetname == "misc_portal_camera1")
                @camera = @ent;
            if (ent.get_classname() == "misc_portal_surface")
                @surface = @ent;
        }
    }

    void parse(String &filename) {
        String file = G_LoadFile("mapscripts/" + filename + ".oms");
        parser.parse(file);
    }

    void initGametype() {
        settings.set();
        classes.init();
    }

    bool command(cClient @client, String &cmd, String &args, int argc) {
        if (cmd == "cvarinfo") {
            GENERIC_CheatVarResponse(client, cmd, args, argc);
            return true;
        } else if (cmd == "class") {
            players.get(client).setClass(args);
            return true;
        } else if (cmd == "gametypemenu") {
            players.get(client).showGameMenu();
            return true;
        } else if (cmd == "classaction1") {
            players.get(client).classAction1();
            return true;
        } else if (cmd == "classaction2") {
            players.get(client).classAction2();
            return true;
        } else if (cmd == "bonusAction") {
            players.get(client).bonusAction();
            return true;
        }
        return false;
    }

    cEntity @selectSpawnPoint(cEntity @self) {
        cEntity @spawn;
        Player @player = players.get(self);
        if (@player != null) {
            @spawn = player.getSpawnPoint();
            if (@spawn != null)
                return spawn;
        }
        @spawn = objectiveSet.randomSpawnPoint(self);
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
        mineSet.think();
        clusterbombSet.think();
        artillerySet.think();
        transporterSet.think();

        if (@camera != null) {
            Vec3 origin = camera.origin;
            Vec3 dir1, dir2, dir3;
            angles.angleVectors(dir1, dir2, dir3);
            //players.say("angles:" + angles.x + "," + angles.y + "," + angles.z);
            //players.say("1:" + dir1.x + "," + dir1.y + "," + dir1.z);
            //players.say("2:" + dir2.x + "," + dir2.y + "," + dir2.z);
            //players.say("3:" + dir3.x + "," + dir3.y + "," + dir3.z);
            //players.say("oldorigin:" + origin.x + "," + origin.y + "," + origin.z);
            origin += (dir1) * 8;
            //players.say("neworigin:" + origin.x + "," + origin.y + "," + origin.z);
            cTrace trace;
            Vec3 zero;
            if (trace.doTrace(camera.origin, Vec3(-132, 0, -88), Vec3(132, 0.1, 88), origin, 0, MASK_SOLID)) {
                origin = trace.get_endPos();
                angles.angleVectors(dir1, dir2, dir3);
                Vec3 normal = trace.get_planeNormal();
                float dot = dir1.x * normal.x + dir1.y * normal.y + dir1.z * normal.z;
                dir1 = Vec3(dir1.x - 2 * normal.x * dot, dir1.y - 2 * normal.y * dot, dir1.z - 2 * normal.z * dot);
                angles = dir1.toAngles();
            }
            camera.origin = origin;
            camera.angles = angles;
            angles.angleVectors(dir1, dir2, dir3);
            surface.skinNum = G_DirToByte(dir1);
        }
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
