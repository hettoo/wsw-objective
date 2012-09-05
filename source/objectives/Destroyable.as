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
const int DESTROY_SCORE_SIMPLE = 2;
const int DEFUSE_SCORE = 4;

class Destroyable : Component {
    Callback @onDestroyed;
    BoolVariable @simple;

    Destroyable(Objective @objective) {
        super(objective);
        @simple = BoolVariable("simple");
        addVariable(simple);
    }

    bool process(String method, String@[] arguments) {
        if (method == "onDestroyed")
            @onDestroyed = parser.createCallback(utils.join(arguments));
        else
            return Component::process(method, arguments);
        return true;
    }

    void destruct(Player @destroyer, bool simple) {
        if (simple && !this.simple.get())
            return;

        players.sound(DESTROY_SOUND.get());
        int team = objective.getOtherTeam();
        objective.destroy();
        String name = objective.getName();
        if (name != "")
            players.say(utils.getTeamName(team) + " has destroyed " + name
                    + "!");
        if (@onDestroyed != null) {
            objective.setActiveTeam(team);
            parser.executeCallback(onDestroyed);
            objective.unsetActiveTeam();
        }
        destroyer.addScore(this.simple.get()
                ? DESTROY_SCORE_SIMPLE : DESTROY_SCORE);
    }

    void planted() {
        String name = objective.getName();
        if (name != "")
            players.say(utils.getTeamName(objective.getOtherTeam())
                    + " planted a bomb at " + name + "!");
        players.sound(PLANT_SOUND.get());
    }

    void defused(Player @defuser) {
        String name = objective.getName();
        if (name != "")
            players.say(utils.getTeamName(objective.getTeam())
                    + " defused the bomb at " + name + "!");
        players.sound(DEFUSE_SOUND.get());
        defuser.addScore(DEFUSE_SCORE);
    }

    void thinkActive(Player @player) {
        if (objective.nearOtherTeam(player))
            player.setHUDStat(STAT_IMAGE_OTHER, simple.get()
                    ? classes.getIcon(CLASS_FIELD_OPS) : DESTROY_ICON.get());
    }
}
