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

const float STEALABLE_WAIT_LIMIT = 15.0f;
const int SECURE_SCORE = 4;
const int RETURN_SCORE = 3;

const Sound STEAL_SOUND("announcer/objective/stolen");
const Sound SECURE_SOUND("announcer/objective/secured");
const Sound DROP_SOUND("announcer/objective/dropped");
const Sound RETURN_SOUND("announcer/objective/returned");

enum StealableState {
    SS_RETURNED,
    SS_STOLEN,
    SS_DROPPED,
    SS_SECURED
}

class Stealable : Component {
    Objective@[] targets;

    int state;
    int[] oldMoveTypes;
    float returnTime;

    Stealable(Objective @objective) {
        super(objective);
        state = SS_RETURNED;
    }

    bool process(String method, String@[] arguments) {
        if (method == "targets") {
            targets.resize(arguments.size());
            for (uint i = 0; i < arguments.size(); i++)
                @targets[i] = objectiveSet.find(arguments[i]);
        } else {
            return Component::process(method, arguments);
        }
        return true;
    }

    bool isSecured() {
        return state == SS_SECURED;
    }

    void stolen(Player @thief) {
        if (objective.getName() != "")
            players.say(utils.getTeamName(thief.getClient().team)
                    + " has stolen the " + objective.getName() + "!");
        players.sound(STEAL_SOUND.get());

        if (state == SS_RETURNED) {
            uint count = objective.getEntityCount();
            oldMoveTypes.resize(count);
            for (uint i = 0; i < count; i++)
                oldMoveTypes[i] = objective.getEntity(i).getMoveType();
        }

        state = SS_STOLEN;
        objective.destroy();
        thief.setCarry(this);
    }

    void dropped(Player @dropper) {
        if (objective.getName() != "")
            players.say(utils.getTeamName(dropper.getClient().team)
                    + " has dropped the " + objective.getName() + "!");
        players.sound(DROP_SOUND.get());

        state = SS_DROPPED;
        dropper.setCarry(null);
        objective.setMoveType(MOVETYPE_TOSS);
        objective.spawn(dropper.getEnt().origin);
        returnTime = STEALABLE_WAIT_LIMIT;
    }

    void resetMoveTypes() {
        uint count = objective.getEntityCount();
        if (count < oldMoveTypes.size())
            count = oldMoveTypes.size();
        for (uint i = 0; i < count; i++)
            objective.getEntity(i).setMoveType(oldMoveTypes[i]);
    }

    bool secured(Player @securer, Objective @target) {
        if (targets.find(target) < 0)
            return false;

        if (objective.getName() != "")
            players.say(utils.getTeamName(securer.getClient().team)
                    + " has secured the " + objective.getName()
                    + (target.getName() == ""
                        ? "" : " at the " + target.getName()) + "!");
        players.sound(SECURE_SOUND.get());
        securer.addScore(SECURE_SCORE);

        resetMoveTypes();

        state = SS_SECURED;
        objective.destroy();

        objectiveSet.goalTest();

        return true;
    }

    void returned(Player @returner) {
        if (objective.getName() != "")
            players.say(utils.getTeamName(objective.getTeam())
                    + " has returned the " + objective.getName() + "!");
        players.sound(RETURN_SOUND.get());
        if (@returner != null)
            returner.addScore(RETURN_SCORE);

        state = SS_RETURNED;
        resetMoveTypes();
        objective.respawn();
    }

    void thinkActive(Player @player) {
        if (objective.nearOtherTeam(player) && @player.getCarry() == null
                && (state == SS_RETURNED || state == SS_DROPPED))
            stolen(player);
        else if (objective.nearOwnTeam(player) && state == SS_DROPPED)
            returned(player);
    }

    void thinkActive() {
        if (state == SS_DROPPED) {
            if (returnTime <= 0)
                returned(null);
            else
                returnTime -= 0.001f * frameTime;
        }
    }
}
