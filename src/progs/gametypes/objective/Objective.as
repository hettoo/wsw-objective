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

class Objective {
    cString id;

    cEntity @ent;
    bool spawned;

    bool start;
    bool solid;
    cString model;
    cVec3 origin;
    cVec3 angles;
    cVec3 mins;
    cVec3 maxs;
    int moveType;
    int team;
    float radius;
    cString message;

    Constructable constructable;
    Destroyable destroyable;
    Spawnable spawnable;

    Objectives @objectives;
    Players @players;

    Objective(cEntity @target, Objectives @objectives, Players @players) {
        id = target.getTargetnameString();
        id = id.substr(1, id.len());
        spawned = false;

        solid = true;
        model = "";
        origin = target.getOrigin();
        angles = target.getAngles();
        moveType = MOVETYPE_NONE;
        start = true;
        team = GS_MAX_TEAMS;
        radius = 150;

        target.unlinkEntity();
        target.freeEntity();

        @this.objectives = objectives;
        @this.players = players;

        constructable.register(this);
        destroyable.register(this);
        spawnable.register(this);
    }

    cString @getId() {
        return id;
    }

    Objectives @getObjectives() {
        return objectives;
    }

    Players @getPlayers() {
        return players;
    }

    void setAttribute(cString &name, cString &value) {
        if (name == "start") {
            start = value.toInt() == 1;
        } else if (name == "solid") {
            solid = value.toInt() == 1;
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
        } else if (name == "radius") {
            radius = value.toInt();
        } else if (name == "message") {
            message = value;
        } else if (constructable.setAttribute(name, value)) {
        } else if (destroyable.setAttribute(name, value)) {
        } else if (spawnable.setAttribute(name, value)) {
        }
    }

    void spawn() {
        if (spawned)
            return;

        if (model != "") {
            @ent = G_SpawnEntity("objective");
            ent.type = ET_GENERIC;
            ent.modelindex = G_ModelIndex("models/" + model + ".md3");
            ent.team = team;
            ent.setOrigin(origin);
            ent.setAngles(angles);
            ent.setSize(mins, maxs);
            ent.solid = solid ? SOLID_YES : SOLID_NOT;
            ent.clipMask = MASK_PLAYERSOLID;
            ent.moveType = moveType;
            ent.svflags &= ~SVF_NOCLIENT;
            ent.linkEntity();
        }

        spawned = true;
    }

    bool isDestroyable() {
        return destroyable.isActive();
    }

    void initialSpawn() {
        if (start)
            spawn();
    }

    void destroy() {
        if (!spawned)
            return;

        if (@ent != null) {
            ent.unlinkEntity();
            ent.freeEntity();
            @ent = null;
        }
        spawned = false;
    }

    bool isSpawn() {
        return spawnable.isActive();
    }

    int getTeam() {
        return team;
    }

    cEntity @getRandomSpawnPoint() {
        return spawnable.getRandomSpawnPoint();
    }

    bool isSpawned() {
        return spawned;
    }

    bool near(cEntity @other) {
        return !other.isGhosting()
            && origin.distance(other.getOrigin()) <= radius;
    }

    bool near(Player @player) {
        return near(player.getEnt());
    }

    bool nearOwnTeam(Player @player) {
        return player.getClient().team == team && near(player);
    }

    bool nearOtherTeam(cEntity @other) {
        return other.team != team && near(other);
    }

    bool nearOtherTeam(Player @player) {
        return nearOtherTeam(player.getEnt());
    }

    void think() {
        if (!spawned)
            return;

        constructable.think();
        destroyable.think();
        spawnable.think();
    }

    void exploded(cEntity @bomb) {
        if (spawned && destroyable.isActive() && nearOtherTeam(bomb))
            destroyable.destruct();
    }

    void planted(cEntity @bomb) {
        if (spawned && destroyable.isActive() && nearOtherTeam(bomb))
            players.sound("announcer/bomb/offense/planted");
    }

    void defused(cEntity @bomb) {
        if (spawned && destroyable.isActive() && nearOtherTeam(bomb))
            players.sound("announcer/bomb/offense/defused");
    }
}
