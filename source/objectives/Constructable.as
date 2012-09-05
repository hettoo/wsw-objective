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
    Objective @ghost;
    Objective @target;
    Callback @onConstructed;
    FloatVariable @constructArmor;

    float constructProgress;
    float constructingSoundWait;
    bool madeProgress;
    float notConstructed;
    bool spawnedGhost;

    Constructable(Objective @objective) {
        super(objective);

        @constructArmor = FloatVariable("constructArmor");
        constructArmor.set(DEFAULT_CONSTRUCT_ARMOR);
        addVariable(constructArmor);

        constructProgress = 0;
        constructingSoundWait = 0;
        madeProgress = false;
        notConstructed = 0;
        spawnedGhost = false;
    }

    bool process(String method, String@[] arguments) {
        if (method == "setGhost")
            @ghost = objectiveSet.find(utils.join(arguments));
        else if (method == "setTarget")
            @target = objectiveSet.find(utils.join(arguments));
        else if (method == "onConstructed")
            @onConstructed = parser.createCallback(utils.join(arguments));
        else
            return Component::process(method, arguments);
        return true;
    }

    void spawnGhost() {
        if (spawnedGhost || @ghost == null)
            return;

        ghost.spawn(0);
        spawnedGhost = true;
    }

    void destroyGhost() {
        if (!spawnedGhost)
            return;

        ghost.destroy();
        spawnedGhost = false;
    }

    void constructed(Player @player) {
        objective.destroy();
        destroyGhost();
        constructProgress = 0;
        players.sound(CONSTRUCTED_SOUND.get());
        int team = player.getTeam();
        if (@target != null) {
            String name = target.getName();
            if (name != "")
                players.say(utils.getTeamName(team) + " has constructed " + name
                        + "!");
            target.spawn(team);
        }
        if (@onConstructed != null) {
            objective.setActiveTeam(team);
            parser.executeCallback(onConstructed);
            objective.unsetActiveTeam();
        }
    }

    void getConstructProgress(Player @player) {
        float additional = CONSTRUCT_SPEED * frameTime;
        constructProgress += additional;
        spawnGhost();
        player.addScore(additional / PROGRESS_FINISHED * constructArmor.get()
                / DEFAULT_CONSTRUCT_ARMOR * CONSTRUCT_SCORE);
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
                            / PROGRESS_FINISHED * constructArmor.get()))
                    getConstructProgress(player);

                player.setHUDStat(STAT_PROGRESS_SELF, constructProgress);
                madeProgress = true;
                notConstructed = 0;
            }
            player.setHUDStat(STAT_IMAGE_OTHER,
                    classes.getIcon(CLASS_ENGINEER));
        }
    }

    void getNotConstructed() {
        notConstructed += 0.001f * frameTime;
        if (notConstructed > CONSTRUCT_WAIT_LIMIT) {
            destroyGhost();
            constructProgress = 0;
            notConstructed = 0;
        }
    }

    void thinkActive() {
        if (constructProgress > 0 && !madeProgress)
            getNotConstructed();
        madeProgress = false;
    }
}
