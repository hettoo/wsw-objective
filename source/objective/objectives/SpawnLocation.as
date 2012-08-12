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
Vec3 FLAG_MINS(-16, -16, -16);
Vec3 FLAG_MAXS(16, 16, 40);

const Image FLAG_ICON("hud/icons/flags/iconflag");
const Sound CAPTURE_SOUND("announcer/objective/captured");

class SpawnLocation : Component {
    bool capturable;
    Objective @alphaFallback;
    Objective @betaFallback;

    SpawnPointSet @spawnPointSet;

    SpawnLocation(Objective @objective) {
        super(objective);
        capturable = false;
    }

    void startProcessor() {
        Component::startProcessor();
        @spawnPointSet = SpawnPointSet();
        spawnPointSet.analyze(objective.getId());
    }

    bool isActive() {
        return Component::isActive() && spawnPointSet.getSize() > 0;
    }

    bool isCapturable() {
        return capturable;
    }

    void lock() {
        applyFallbacks();
        capturable = false;
        objective.respawn();
    }

    bool process(String method, String@[] arguments) {
        if (method == "capturable") {
            capturable = arguments[0].toInt() == 1;
        } else if (method == "alphaFallback") {
            @alphaFallback = objectiveSet.find(arguments[0]);
        } else if (method == "betaFallback") {
            @betaFallback = objectiveSet.find(arguments[0]);
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
            case TEAM_ALPHA:
                ent.modelindex = FLAG.get();
                break;
            case TEAM_BETA:
                ent.modelindex = FLAG.get();
                break;
            default:
                ent.modelindex = FLAG_UNCAPTURED.get();
                break;
        }
        Vec3 origin = objective.origin;
        ent.origin = origin;
        ent.angles = Vec3(-90, 0, 0);
        ent.setSize(FLAG_MINS, FLAG_MAXS);
        ent.solid = SOLID_YES;
        ent.clipMask = MASK_PLAYERSOLID;
        ent.moveType = MOVETYPE_NONE;
        ent.svflags &= ~SVF_NOCLIENT;
        ent.linkEntity();
        objective.setEnt(ent);
        objective.setIcon(utils.spawnIcon(FLAG_ICON.get(), ent.team, origin));
    }

    cEntity @getRandomSpawnPoint() {
        return spawnPointSet.getRandom();
    }

    void applyFallbacks(int team) {
        if (@alphaFallback != null) {
            if (team == TEAM_ALPHA)
                alphaFallback.destroy();
            else if (team == TEAM_BETA)
                alphaFallback.spawn();
        }
        if (@betaFallback != null) {
            if (team == TEAM_ALPHA)
                betaFallback.spawn();
            else if (team == TEAM_BETA)
                betaFallback.destroy();
        }
    }

    void applyFallbacks() {
        applyFallbacks(objective.getTeam());
    }

    void captured(Player @capturer) {
        int team = capturer.getClient().team;
        if (objective.getName() != "")
            players.say(utils.getTeamName(team)
                    + " has captured the " + objective.getName() + "!");
        players.sound(CAPTURE_SOUND.get());
        capturer.addScore(CAPTURE_SCORE);
        applyFallbacks(team);
        objective.respawn(team);
    }

    void thinkActive(Player @player) {
        if (capturable && objective.getTeam() != player.getClient().team)
            captured(player);
    }
}
