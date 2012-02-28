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

const int SECURE_SCORE = 4;
const int RETURN_SCORE = 3;

const Sound STEAL_SOUND("announcer/objective/stolen");
const Sound SECURE_SOUND("announcer/objective/secured");
const Sound DROP_SOUND("announcer/objective/dropped");
const Sound RETURN_SOUND("announcer/objective/returned");

class Stealable : Component {
    Objective @objective;

    ResultSet @targets;

    Stealable(Objective @objective) {
        @this.objective = objective;
    }

    bool setAttribute(cString &name, cString &value) {
        if (name == "stealable")
            active = value.toInt() == 1;
        else if (name == "targets")
            @targets = ResultSet(value, objective.getObjectiveSet());
        else
            return false;
        return true;
    }

    void stolen(Player @thief) {
        Players @players = objective.getPlayers();
        if (objective.getName() != "")
            players.say(G_GetTeamName(thief.getClient().team)
                    + " has stolen the " + objective.getName() + "!");
        players.sound(STEAL_SOUND.get());

        objective.destroy();
        // TODO: set carrier stuff
    }

    void dropped(Player @dropper) {
        Players @players = objective.getPlayers();
        if (objective.getName() != "")
            players.say(G_GetTeamName(dropper.getClient().team)
                    + " has dropped the " + objective.getName() + "!");
        players.sound(DROP_SOUND.get());

        objective.destroy();
        // TODO: remove carrier stuff, throw the model (spawning the objective)
    }

    void secured(Player @securer, Objective @target) {
        Players @players = objective.getPlayers();
        if (objective.getName() != "")
            players.say(G_GetTeamName(securer.getClient().team)
                    + " has secured the " + objective.getName() + "!");
        players.sound(SECURE_SOUND.get());
        securer.addScore(SECURE_SCORE);

        objective.destroy();
        // TODO: set the target model to this objectives model
    }

    void returned(Player @returner) {
        Players @players = objective.getPlayers();
        if (objective.getName() != "")
            players.say(G_GetTeamName(returner.getClient().team)
                    + " has returned the " + objective.getName() + "!");
        players.sound(RETURN_SOUND.get());
        securer.addScore(RETURN_SCORE);

        objective.respawn();
    }

    void thinkActive(Player @player) {
        if (objective.nearOtherTeam(player))
            player.setHUDStat(STAT_IMAGE_OTHER, DESTROY_ICON.get());
    }
}
