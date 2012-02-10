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

const float CONSTRUCT_SPEED = 0.012f;
const float CONSTRUCT_WAIT_LIMIT = 15.0f;

class Objective {
    cString id;
    bool spawned;
    cEntity @ent;

    bool start;
    cString model;
    cVec3 origin;
    cVec3 mins;
    cVec3 maxs;
    int moveType;
    int team;

    bool constructable;
    float constructArmor;
    cString constructing;
    cString constructed;

    bool destroyable;
    cString destroyed;

    float radius;

    cString message;

    float constructProgress;
    float notConstructed;
    bool spawnedGhost;

    Objectives @objectives;
    Players @players;

    Objective(cEntity @ent, Objectives @objectives, Players @players) {
        id = ent.getTargetnameString();
        id = id.substr(1, id.len());
        spawned = false;

        model = "";
        origin = ent.getOrigin();
        moveType = MOVETYPE_NONE;
        start = true;
        team = GS_MAX_TEAMS;

        constructable = false;
        constructArmor = 80;

        destroyable = false;

        radius = 150;

        ent.unlinkEntity();
        ent.freeEntity();

        constructProgress = 0;
        notConstructed = 0;
        spawnedGhost = false;

        @this.objectives = objectives;
        @this.players = players;
    }

    cString @getId() {
        return id;
    }

    void setAttribute(cString &name, cString &value) {
        if (name == "start") {
            start = value.toInt() == 1;
        } else if (name == "model") {
            model = value;
        } else if (name == "moveType") {
            moveType = value.toInt();
        } else if (name == "mins") {
            mins = cVec3(value.getToken(0).toFloat(),
                    value.getToken(1).toFloat(), value.getToken(2).toFloat());
        } else if (name == "maxs") {
            maxs = cVec3(value.getToken(0).toFloat(),
                    value.getToken(1).toFloat(), value.getToken(2).toFloat());
        } else if (name == "team") {
            if (value == "ASSAULT")
                team = TEAM_ASSAULT;
            else if (value == "DEFENSE")
                team = TEAM_DEFENSE;
        } else if (name == "constructable") {
            constructable = value.toInt() == 1;
        } else if (name == "constructArmor") {
            constructArmor = value.toInt();
        } else if (name == "constructing") {
            constructing = value;
        } else if (name == "constructed") {
            constructed = value;
        } else if (name == "destroyable") {
            destroyable = value.toInt() == 1;
        } else if (name == "destroyed") {
            destroyed = value;
        } else if (name == "radius") {
            radius = value.toInt();
        } else if (name == "message") {
            message = value;
        }
    }

    void spawn() {
        if (spawned)
            return;

        @ent = G_SpawnEntity("objective");
        ent.type = ET_GENERIC;
        ent.modelindex = G_ModelIndex("models/" + model + ".md3");
        ent.modelindex2 = ent.modelindex;
        ent.team = team;
        ent.setOrigin(origin);
        ent.setSize(mins, maxs);
        ent.solid = SOLID_YES;
        ent.clipMask = MASK_PLAYERSOLID;
        ent.moveType = moveType;
        ent.svflags &= ~SVF_NOCLIENT;
        ent.linkEntity();

        spawned = true;
    }

    void initialSpawn() {
        if (start)
            spawn();
    }

    void destroy() {
        if (!spawned)
            return;

        ent.unlinkEntity();
        ent.freeEntity();
        @ent = null;
        spawned = false;
    }

    void spawnGhost() {
        if (spawnedGhost || constructing == "")
            return;

        objectives.find(constructing).spawn();
        spawnedGhost = true;
    }

    void destroyGhost() {
        if (!spawnedGhost)
            return;

        objectives.find(constructing).destroy();
        spawnedGhost = false;
    }

    void spawnConstructed() {
        if (constructed == "")
            return;

        objectives.find(constructed).spawn();
    }

    bool canInteractWith(Player @player) {
        return player.getClient().team == team
            && player.getClass() == CLASS_ENGINEER
            && ent.getOrigin().distance(player.getEnt().getOrigin()) <= radius;
    }

    void constructed() {
        destroy();
        destroyGhost();
        spawnConstructed();
        constructProgress = 0;
        G_PrintMsg(null, message + "\n");
    }

    void constructProgress() {
        constructProgress += CONSTRUCT_SPEED * frameTime;
        spawnGhost();
    }

    bool construct() {
        bool madeConstructProgress = false;
        for (int i = 0; i < players.getSize(); i++) {
            Player @player = players.get(i);
            if (@player != null && constructable && canInteractWith(player)) {
                if (constructProgress >= PROGRESS_FINISHED)
                    constructed();
                else if (player.takeArmor(CONSTRUCT_SPEED * frameTime
                            / PROGRESS_FINISHED * constructArmor))
                    constructProgress();

                player.getClient().setHUDStat(STAT_PROGRESS_SELF,
                        constructProgress);
                madeConstructProgress = true;
                notConstructed = 0;
            }
        }

        return madeConstructProgress;
    }

    void notConstructed() {
        notConstructed += 0.001f * frameTime;
        if (notConstructed > CONSTRUCT_WAIT_LIMIT) {
            destroyGhost();
            constructProgress = 0;
            notConstructed = 0;
        }
    }

    void think() {
        if (!spawned || (!constructable && !destroyable))
            return;

        bool madeConstructProgress = construct();

        if (constructable && constructProgress > 0 && !madeConstructProgress)
            notConstructed();
    }
}
