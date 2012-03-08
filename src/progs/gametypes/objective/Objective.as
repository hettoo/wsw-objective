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

    cString name;
    cEntity @ent;
    cEntity @minimap;
    bool spawned;
    int owningTeam;

    bool startSpawned;
    bool solid;
    int model;
    int icon;
    cVec3 origin;
    cVec3 angles;
    cVec3 mins;
    cVec3 maxs;
    int moveType;
    int team;
    float radius;

    Constructable @constructable;
    Destroyable @destroyable;
    SpawnLocation @spawnLocation;
    Stealable @stealable;
    SecureLocation @secureLocation;

    Objective(cEntity @target) {
        id = target.getTargetnameString();
        id = id.substr(1, id.len());
        spawned = false;

        solid = true;
        model = 0;
        origin = target.getOrigin();
        angles = target.getAngles();
        moveType = MOVETYPE_NONE;
        startSpawned = true;
        team = GS_MAX_TEAMS;
        owningTeam = team;
        radius = 125;

        target.unlinkEntity();
        target.freeEntity();

        @constructable = Constructable(this);
        @destroyable = Destroyable(this);
        @spawnLocation = SpawnLocation(this);
        @stealable = Stealable(this);
        @secureLocation = SecureLocation(this);
    }

    cString @getId() {
        return id;
    }

    cString @getName() {
        return name;
    }

    cVec3 @getOrigin() {
        return origin;
    }

    int getModel() {
        return model;
    }

    void setModel(int model) {
        this.model = model;
    }

    void setEnt(cEntity @ent) {
        @this.ent = ent;
    }

    int getIcon() {
        return icon;
    }

    void setIcon(cEntity @minimap) {
        @this.minimap = minimap;
    }

    void setAttribute(cString &name, cString &value) {
        if (name == "name") {
            this.name = value;
        } else if (name == "startSpawned") {
            startSpawned = value.toInt() == 1;
        } else if (name == "solid") {
            solid = value.toInt() == 1;
        } else if (name == "model") {
            model = Model(value).get();
        } else if (name == "icon") {
            icon = Image(value).get();
        } else if (name == "moveType") {
            moveType = value.toInt();
        } else if (name == "mins") {
            mins = cVec3(value.getToken(0).toFloat(),
                    value.getToken(1).toFloat(), value.getToken(2).toFloat());
        } else if (name == "maxs") {
            maxs = cVec3(value.getToken(0).toFloat(),
                    value.getToken(1).toFloat(), value.getToken(2).toFloat());
        } else if (name == "team") {
            if (value.tolower() == "alpha")
                team = TEAM_ALPHA;
            else if (value.tolower() == "beta")
                team = TEAM_BETA;
            owningTeam = team;
        } else if (name == "radius") {
            radius = value.toInt();
        } else if (constructable.setAttribute(name, value)) {
        } else if (destroyable.setAttribute(name, value)) {
        } else if (spawnLocation.setAttribute(name, value)) {
        } else if (stealable.setAttribute(name, value)) {
        } else if (secureLocation.setAttribute(name, value)) {
        }
    }

    void spawn(cVec3 @origin) {
        if (spawned)
            return;

        if (spawnLocation.isActive() && spawnLocation.isCapturable()) {
            spawnLocation.spawn();
        } else {
            if (model != 0) {
                @ent = G_SpawnEntity("objective");
                ent.type = ET_GENERIC;
                ent.modelindex = model;
                ent.team = owningTeam;
                ent.setOrigin(origin);
                ent.setAngles(angles);
                ent.setSize(mins, maxs);
                ent.solid = solid ? SOLID_YES : SOLID_NOT;
                ent.clipMask = MASK_PLAYERSOLID;
                ent.moveType = moveType;
                ent.svflags &= ~SVF_NOCLIENT;
                ent.linkEntity();
            }

            if (icon != 0)
                @minimap = G_SpawnIcon(icon, owningTeam, origin);

        }

        spawned = true;
    }

    void spawn() {
        spawn(origin);
    }

    void spawn(int team) {
        owningTeam = team;
        spawn();
    }

    void lock() {
        spawnLocation.lock();
    }

    void lock(int team) {
        owningTeam = team;
        lock();
    }

    bool isDestroyable() {
        return destroyable.isActive();
    }

    void initialSpawn() {
        if (startSpawned)
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
        if (@minimap != null) {
            minimap.unlinkEntity();
            minimap.freeEntity();
            @minimap = null;
        }
        spawned = false;
        owningTeam = team;
    }

    void respawn(int team) {
        destroy();
        spawn(team);
    }

    void respawn() {
        respawn(owningTeam);
    }

    bool isSecured() {
        return stealable.isActive() && stealable.isSecured();
    }

    bool isSpawn() {
        return spawnLocation.isActive();
    }

    int getTeam() {
        return owningTeam;
    }

    void setTeam(int team) {
        owningTeam = team;
    }

    int getOtherTeam() {
        return players.otherTeam(owningTeam);
    }

    cEntity @getRandomSpawnPoint() {
        return spawnLocation.getRandomSpawnPoint();
    }

    bool isSpawned() {
        return spawned;
    }

    bool near(cEntity @other) {
        return G_Near(@ent == null ? origin : ent.getOrigin(),
                other.getOrigin(), radius);
    }

    bool near(Player @player) {
        return near(player.getEnt());
    }

    bool nearOwnTeam(Player @player) {
        return (owningTeam == GS_MAX_TEAMS
                || player.getClient().team == owningTeam) && near(player);
    }

    bool nearOtherTeam(cEntity @other) {
        return other.team != owningTeam && near(other);
    }

    bool nearOtherTeam(Player @player) {
        return nearOtherTeam(player.getEnt());
    }

    void think() {
        if (!spawned)
            return;

        for (int i = 0; i < players.getSize(); i++) {
            Player @player = players.get(i);
            if (@player != null && near(player)) {
                if (name != "") {
                    int configStringId = CS_GENERAL
                        + player.getClient().playerNum();
                    G_ConfigString(configStringId, "You are near the " + name);
                    player.setHUDStat(STAT_MESSAGE_SELF, configStringId);
                }
                constructable.think(player);
                destroyable.think(player);
                spawnLocation.think(player);
                stealable.think(player);
                secureLocation.think(player);
            }
        }

        constructable.think();
        destroyable.think();
        spawnLocation.think();
        stealable.think();
        secureLocation.think();
    }

    void exploded(cEntity @bomb, Player @planter) {
        if (spawned && destroyable.isActive() && nearOtherTeam(bomb))
            destroyable.destruct(planter);
    }

    bool planted(cEntity @bomb) {
        if (spawned && destroyable.isActive() && nearOtherTeam(bomb)) {
            destroyable.planted();
            return true;
        }
        return false;
    }

    void defused(cEntity @bomb, Player @defuser) {
        if (spawned && destroyable.isActive() && nearOtherTeam(bomb))
            destroyable.defused(defuser);
    }
}
