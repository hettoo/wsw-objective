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

class StandardProcessor : Processor {
    bool process(String method, String@[] arguments) {
        if (method == "author")
            gametype.author = AUTHOR
                    + S_COLOR_ORANGE + " (map by " + S_COLOR_WHITE
                    + utils.join(arguments) + S_COLOR_ORANGE + ")";
        else if (method == "goal")
            objectiveSet.setGoal(ResultSet(arguments));
        else
            return false;
        return true;
    }

    Processor @subProcessor(String target) {
        Objective @objective = objectiveSet.find(target);
        if (@objective != null)
            return objective;
        if (target == "players")
            return players;
        return null;
    }
}
