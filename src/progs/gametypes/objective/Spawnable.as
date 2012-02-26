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

const int CAPTURE_SCORE = 2;

const Model FLAG("objects/flag/flag");
const Model FLAG_UNCAPTURED("misc/ammobox");
cVec3 FLAG_MINS(-16, -16, -16);
cVec3 FLAG_MAXS(16, 16, 40);

const Image FLAG_ICON("hud/icons/flags/iconflag");
const Sound CAPTURE_SOUND("announcer/objective/captured");

class Spawnable : Component {
    bool capturable;
    Objective @assaultFallback;
    Objective @defenseFallback;

    SpawnPointSet @spawnPointSet;

    Objective @objective;

    Spawnable(Objective @objective) {
        capturable = false;

        @this.objective = objective;
    }

    bool isActive() {
        return Component::isActive() && spawnPointSet.getSize() > 0;
    }

    bool isCapturable() {
        return capturable;
    }

    bool setAttribute(cString &name, cString &value) {
        if (name == "spawnLocation") {
            active = value.toInt() == 1;
            @spawnPointSet = SpawnPointSet();
            spawnPointSet.analyze(objective.getId());
        } else if (name == "capturable") {
            capturable = value.toInt() == 1;
        } else if (name == "assaultFallback") {
            @assaultFallback = objective.getObjectiveSet().find(value);
        } else if (name == "defenseFallback") {
            @defenseFallback = objective.getObjectiveSet().find(value);
        } else {
            return false;
        }
        return true;
    }

    void spawn() {
        cEntity @ent = G_SpawnEntity("objective");
        ent.type = ET_GENERIC;
        ent.team = objective.getTeam();
        switch (ent.team) {
            case TEAM_DEFENSE:
                ent.modelindex = FLAG.get();
                break;
            case TEAM_ASSAULT:
                ent.modelindex = FLAG.get();
                break;
            default:
                ent.modelindex = FLAG_UNCAPTURED.get();
                break;
        }
        cVec3 @origin = objective.getOrigin();
        ent.setOrigin(origin);
        ent.setAngles(cVec3(-90, 0, 0));
        ent.setSize(FLAG_MINS, FLAG_MAXS);
        ent.solid = SOLID_YES;
        ent.clipMask = MASK_PLAYERSOLID;
        ent.moveType = MOVETYPE_NONE;
        ent.svflags &= ~SVF_NOCLIENT;
        ent.linkEntity();
        objective.setEnt(ent);
        objective.setIcon(G_SpawnIcon(FLAG_ICON.get(), ent.team, origin));
    }

    cEntity @getRandomSpawnPoint() {
        return spawnPointSet.getRandom();
    }

    void captured(int team, Player @capturer) {
        Players @players = objective.getPlayers();
        if (objective.getName() != "")
            players.say(G_GetTeamName(team)
                    + " has captured the " + objective.getName() + "!");
        players.sound(CAPTURE_SOUND.get());
        capturer.addScore(CAPTURE_SCORE);
        if (@assaultFallback != null) {
            if (team == TEAM_ASSAULT)
                assaultFallback.destroy();
            else if (team == TEAM_DEFENSE)
                assaultFallback.spawn();
        }
        if (@defenseFallback != null) {
            if (team == TEAM_DEFENSE)
                defenseFallback.destroy();
            else if (team == TEAM_ASSAULT)
                defenseFallback.spawn();
        }
        objective.respawn(team);
    }

    void thinkActive(Player @player) {
        int playerTeam = player.getClient().team;
        if (capturable && objective.getTeam() != playerTeam)
            captured(playerTeam, player);
    }
}
