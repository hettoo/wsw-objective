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

const Image DESTROY_ICON("bomb/carriericon");

const Sound PLANT_SOUND("announcer/objective/planted");
const Sound DEFUSE_SOUND("announcer/objective/defused");
const Sound DESTROY_SOUND("announcer/objective/destroyed");

const int DESTROY_SCORE = 4;
const int DEFUSE_SCORE = 4;

class Destroyable : Component {
    Callback @onDestroyed;

    Destroyable(Objective @objective) {
        super(objective);
    }

    bool process(String method, String@[] arguments) {
        if (method == "onDestroyed")
            @onDestroyed = parser.createCallback(utils.join(arguments));
        else
            return Component::process(method, arguments);
        return true;
    }

    void destruct(Player @planter) {
        players.sound(DESTROY_SOUND.get());
        int team = objective.getOtherTeam();
        objective.destroy();
        String name = objective.getName();
        if (name != "")
            players.say(utils.getTeamName(team) + " has destroyed the " + name
                    + "!");
        if (@onDestroyed != null) {
            objective.setActiveTeam(team);
            parser.executeCallback(onDestroyed);
            objective.unsetActiveTeam();
        }
        planter.addScore(DESTROY_SCORE);
    }

    void planted() {
        if (objective.getName() != "")
            players.say(utils.getTeamName(objective.getOtherTeam())
                    + " planted a bomb at the " + objective.getName() + "!");
        players.sound(PLANT_SOUND.get());
    }

    void defused(Player @defuser) {
        if (objective.getName() != "")
            players.say(utils.getTeamName(objective.getTeam())
                    + " defused the bomb at the " + objective.getName() + "!");
        players.sound(DEFUSE_SOUND.get());
        defuser.addScore(DEFUSE_SCORE);
    }

    void thinkActive(Player @player) {
        if (objective.nearOtherTeam(player))
            player.setHUDStat(STAT_IMAGE_OTHER, DESTROY_ICON.get());
    }
}
