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
const int CONSTRUCT_SCORE = 4;
const float CONSTRUCTING_SOUND_DELAY = 1.2f;
const float ATTN_CONSTRUCTING = 0.75f;

const Sound CONSTRUCTING_SOUND("objective/constructing");
const Sound CONSTRUCTED_SOUND("announcer/objective/constructed");

class Constructable : Component {
    float constructArmor;
    Objective @onConstructing;
    Objective @onConstructed;

    float constructProgress;
    float constructingSoundWait;
    bool madeProgress;
    float notConstructed;
    bool spawnedGhost;

    Objective @objective;

    Constructable(Objective @objective) {
        constructArmor = DEFAULT_CONSTRUCT_ARMOR;

        constructProgress = 0;
        constructingSoundWait = 0;
        madeProgress = false;
        notConstructed = 0;
        spawnedGhost = false;

        @this.objective = objective;
    }

    bool setAttribute(cString &name, cString &value) {
        if (name == "constructable")
            active = value.toInt() == 1;
        else if (name == "constructArmor")
            constructArmor = value.toInt();
        else if (name == "onConstructing")
            @onConstructing = objective.getObjectiveSet().find(value);
        else if (name == "onConstructed")
            @onConstructed = objective.getObjectiveSet().find(value);
        else
            return false;
        return true;
    }

    void spawnGhost() {
        if (spawnedGhost || @onConstructing == null)
            return;

        onConstructing.spawn(0);
        spawnedGhost = true;
    }

    void destroyGhost() {
        if (!spawnedGhost)
            return;

        onConstructing.destroy();
        spawnedGhost = false;
    }

    void spawnConstructed(Player @player) {
        if (@onConstructed == null)
            return;

        int team = player.getClient().team;
        onConstructed.spawn(team);
        Players @players = objective.getPlayers();
        cString name = onConstructed.getName();
        if (name != "")
            players.say(G_GetTeamName(team)
                    + " has constructed the " + name + "!");
        players.sound(CONSTRUCTED_SOUND.get());
        objective.getObjectiveSet().goalTest();
    }

    void constructed(Player @player) {
        spawnConstructed(player);
        objective.destroy();
        destroyGhost();
        constructProgress = 0;
    }

    void constructProgress(Player @player) {
        float additional = CONSTRUCT_SPEED * frameTime;
        constructProgress += additional;
        spawnGhost();
        player.addScore(additional / PROGRESS_FINISHED
                * constructArmor / DEFAULT_CONSTRUCT_ARMOR * CONSTRUCT_SCORE);
        if (constructingSoundWait <= 0) {
            G_Sound(player.getEnt(), CHAN_AUTO,
                    CONSTRUCTING_SOUND.get(), ATTN_CONSTRUCTING);
            constructingSoundWait = CONSTRUCTING_SOUND_DELAY;
        } else {
            constructingSoundWait -= frameTime * 0.001;
        }
    }

    void thinkActive(Player @player) {
        if (objective.nearOwnTeam(player)) {
            if (player.getClassId() == CLASS_ENGINEER) {
                if (constructProgress >= PROGRESS_FINISHED)
                    constructed(player);
                else if (player.takeArmor(CONSTRUCT_SPEED * frameTime
                            / PROGRESS_FINISHED * constructArmor))
                    constructProgress(player);

                player.setHUDStat(STAT_PROGRESS_SELF, constructProgress);
                madeProgress = true;
                notConstructed = 0;
            }
            player.setHUDStat(STAT_IMAGE_OTHER,
                    objective.getPlayers().getClasses().getIcon(
                        CLASS_ENGINEER));
        }
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
        if (constructProgress > 0 && !madeProgress)
            notConstructed();
        madeProgress = false;
    }
}
