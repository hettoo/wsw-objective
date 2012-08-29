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

class Objective : Processor {
    String id;

    ObjectiveEntity@[] entities;

    String name;
    Vec3 origin;
    Vec3 angles;
    cEntity @minimap;
    bool spawned;
    int owningTeam;
    int activeTeam;

    int icon;
    int team;
    float radius;

    Constructable @constructable;
    Destroyable @destroyable;
    SpawnLocation @spawnLocation;
    Stealable @stealable;
    SecureLocation @secureLocation;

    Objective(cEntity @target) {
        id = target.get_targetname();
        id = id.substr(1);
        spawned = false;

        team = GS_MAX_TEAMS;
        radius = 125;

        owningTeam = team;
        unsetActiveTeam();

        origin = target.origin;
        angles = target.angles;

        target.unlinkEntity();
        target.freeEntity();

        @constructable = Constructable(this);
        @destroyable = Destroyable(this);
        @spawnLocation = SpawnLocation(this);
        @stealable = Stealable(this);
        @secureLocation = SecureLocation(this);
    }

    String @getId() {
        return id;
    }

    String @getName() {
        return name;
    }

    Vec3 getOrigin() {
        return origin;
    }

    int getIcon() {
        return icon;
    }

    void setActiveTeam(int team) {
        this.activeTeam = team;
    }

    void unsetActiveTeam() {
        this.activeTeam = GS_MAX_TEAMS;
    }

    void setIcon(int icon) {
        this.icon = icon;
    }

    bool process(String method, String@[] arguments) {
        if (method == "name") {
            this.name = utils.join(arguments);
        } else if (method == "radius") {
            radius = arguments[0].toInt();
        } else if (method == "icon") {
            icon = Image(utils.join(arguments)).get();
        } else if (method == "team") {
            team = arguments[0].toInt();
            owningTeam = team;
        } else if (method == "spawn") {
            spawn();
        } else if (method == "spawnObjective") {
            objectiveSet.find(arguments[0]).spawn(activeTeam);
        } else if (method == "spawnObjectiveOther") {
            objectiveSet.find(arguments[0]).spawn(
                    players.otherTeam(activeTeam));
        } else if (method == "capture") {
            objectiveSet.find(arguments[0]).lock(activeTeam);
        } else {
            return Processor::process(method, arguments);
        }
        return true;
    }

    Processor @subProcessor(String target) {
        if (target == "constructable")
            return constructable;
        if (target == "destroyable")
            return destroyable;
        if (target == "spawnLocation")
            return spawnLocation;
        if (target == "stealable")
            return stealable;
        if (target == "secureLocation")
            return secureLocation;
        if (target == "entity")
            return addEntity();
        for (uint i = 0; i < entities.size(); i++) {
            if (entities[i].getId() == target)
                return entities[i];
        }
        return Processor::subProcessor(target);
    }

    void addEntity(ObjectiveEntity @entity) {
        entities.insertLast(entity);
    }

    ObjectiveEntity @addEntity() {
        ObjectiveEntity @entity = ObjectiveEntity(this);
        addEntity(entity);
        return entity;
    }

    ObjectiveEntity @getEntity(uint index) {
        return entities[index];
    }

    Vec3 getAngles() {
        return angles;
    }

    float getRadius() {
        return radius;
    }

    int getOwningTeam() {
        return owningTeam;
    }

    void setMoveType(int moveType) {
        for (uint i = 0; i < entities.size(); i++)
            entities[i].setMoveType(moveType);
    }

    uint getEntityCount() {
        return entities.size();
    }

    void spawn(Vec3 origin) {
        if (spawned)
            return;

        for (uint i = 0; i < entities.size(); i++)
            entities[i].spawn(origin);

        if (icon != 0)
            @minimap = utils.spawnIcon(icon, owningTeam, origin);

        spawned = true;

        objectiveSet.goalTest();
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

    void destroyIcon() {
        if (@minimap != null) {
            minimap.unlinkEntity();
            minimap.freeEntity();
            @minimap = null;
        }
    }

    void destroy(bool goalTest) {
        if (!spawned)
            return;

        for (uint i = 0; i < entities.size(); i++)
            entities[i].destroy();

        destroyIcon();
        spawned = false;
        owningTeam = team;

        if (goalTest)
            objectiveSet.goalTest();
    }

    void destroy() {
        destroy(true);
    }

    void respawn(int team) {
        destroy(false);
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
        if (entities.size() == 0)
            return utils.near(origin, other.origin, radius);
        for (uint i = 0; i < entities.size(); i++) {
            if (entities[i].near(other))
                return true;
        }
        return false;
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
                        + player.getClient().playerNum;
                    G_ConfigString(configStringId, "You are near " + getName());
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

    void destroyed(cEntity @bomb, Player @destroyer, bool light) {
        if (spawned && destroyable.isActive() && nearOtherTeam(bomb))
            destroyable.destruct(destroyer, light);
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
