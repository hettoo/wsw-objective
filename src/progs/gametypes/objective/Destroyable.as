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

const Image DESTROY_ICON("bomb/carrierIcon");

const Sound PLANT_SOUND("announcer/objective/planted");
const Sound DEFUSE_SOUND("announcer/objective/defused");
const Sound DESTROY_SOUND("announcer/objective/destroyed");

class Destroyable : Component {
    cString destroyed;

    Objective @objective;

    Destroyable(Objective @objective) {
        @this.objective = objective;
    }

    bool setAttribute(cString &name, cString &value) {
        if (name == "destroyable")
            active = value.toInt() == 1;
        else if (name == "destroyed")
            destroyed = value;
        else
            return false;
        return true;
    }

    void destruct() {
        Players @players = objective.getPlayers();
        if (objective.getName() != "")
            players.say(G_GetTeamName(objective.getOtherTeam())
                    + " has destroyed " + objective.getName() + "!");
        players.sound(DESTROY_SOUND.get());

        objective.destroy();
        if (destroyed != "")
            objective.getObjectiveSet().find(destroyed).spawn();
    }

    void planted() {
        Players @players = objective.getPlayers();
        if (objective.getName() != "")
            players.say(G_GetTeamName(objective.getOtherTeam())
                    + " planted a bomb at " + objective.getName() + "!");
        players.sound(PLANT_SOUND.get());
    }

    void defused() {
        if (objective.getName() != "")
            objective.getPlayers().say(G_GetTeamName(objective.getTeam())
                    + " defused the bomb at " + objective.getName() + "!");
        objective.getPlayers().sound(DEFUSE_SOUND.get());
    }

    void thinkActive(Player @player) {
        if (objective.nearOtherTeam(player))
            player.setHUDStat(STAT_IMAGE_OTHER, DESTROY_ICON.get());
    }
}
