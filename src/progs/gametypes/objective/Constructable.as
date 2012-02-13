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

const int DEFAULT_CONSTRUCT_ARMOR = BOMB_ARMOR;
const float CONSTRUCT_SPEED = 0.012f;
const float CONSTRUCT_WAIT_LIMIT = 15.0f;

class Constructable : Component {
    float constructArmor;
    cString constructing;
    cString constructed;

    float constructProgress;
    float notConstructed;
    bool spawnedGhost;

    int constructOwnSound;
    int constructOtherSound;

    Objective @objective;

    Constructable() {
        active = false;
        constructArmor = DEFAULT_CONSTRUCT_ARMOR;

        constructProgress = 0;
        notConstructed = 0;
        spawnedGhost = false;
    }

    void register(Objective @objective) {
        @this.objective = objective;

        constructOwnSound
            = objective.getPlayers().soundIndex("announcer/bomb/defense/start");
        constructOtherSound
            = objective.getPlayers().soundIndex("announcer/bomb/offense/start");
    }

    bool setAttribute(cString &name, cString &value) {
        if (name == "constructable")
            active = value.toInt() == 1;
        else if (name == "constructArmor")
            constructArmor = value.toInt();
        else if (name == "constructing")
            constructing = value;
        else if (name == "constructed")
            constructed = value;
        else
            return false;
        return true;
    }

    void spawnGhost() {
        if (spawnedGhost || constructing == "")
            return;

        objective.getObjectiveSet().find(constructing).spawn();
        spawnedGhost = true;
    }

    void destroyGhost() {
        if (!spawnedGhost)
            return;

        objective.getObjectiveSet().find(constructing).destroy();
        spawnedGhost = false;
    }

    void spawnConstructed() {
        if (constructed == "")
            return;

        Objective @new = objective.getObjectiveSet().find(constructed);
        new.spawn();
        if (new.isDestroyable()) {
            objective.getPlayers().sound(objective.getTeam(),
                    constructOwnSound);
            objective.getPlayers().sound(
                    objective.getPlayers().otherTeam(objective.getTeam()),
                    constructOtherSound);
        }
        objective.getObjectiveSet().goalTest();
    }

    void constructed() {
        spawnConstructed();
        objective.destroy();
        destroyGhost();
        constructProgress = 0;
        objective.getPlayers().say(objective.message);
    }

    void constructProgress() {
        constructProgress += CONSTRUCT_SPEED * frameTime;
        spawnGhost();
    }

    bool checkPlayers() {
        bool madeConstructProgress = false;
        int players = objective.getPlayers().getSize();
        for (int i = 0; i < players; i++) {
            Player @player = objective.getPlayers().get(i);
            if (@player != null && objective.nearOwnTeam(player)) {
                if (player.getClassId() == CLASS_ENGINEER) {
                    if (constructProgress >= PROGRESS_FINISHED)
                        constructed();
                    else if (player.takeArmor(CONSTRUCT_SPEED * frameTime
                                / PROGRESS_FINISHED * constructArmor))
                        constructProgress();

                    player.setHUDStat(STAT_PROGRESS_SELF, constructProgress);
                    madeConstructProgress = true;
                    notConstructed = 0;
                }
                player.setHUDStat(STAT_IMAGE_OTHER,
                        player.getClassIcon(CLASS_ENGINEER));
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

    void thinkActive() {
        bool madeProgress = checkPlayers();
        if (constructProgress > 0 && !madeProgress)
            notConstructed();
    }
}
