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
    bool conditionSucceeded;

    StandardProcessor() {
        conditionSucceeded = false;
    }

    bool checkCondition(String@[] arguments) {
        if (arguments[0] == "eq")
            conditionSucceeded = arguments[1] == arguments[2];
        else if (arguments[0] == "ne")
            conditionSucceeded = arguments[1] != arguments[2];
        else
            conditionSucceeded = false;
        return conditionSucceeded;
    }

    bool process(String method, String@[] arguments) {
        if (method == "if") {
            if (checkCondition(arguments))
                parser.parse(arguments[arguments.size() - 1]);
        } else if (method == "elsif") {
            if (!conditionSucceeded && checkCondition(arguments))
                parser.parse(arguments[arguments.size() - 1]);
        } else if (method == "also") {
            if (conditionSucceeded)
                parser.parse(arguments[0]);
        } else if (method == "else") {
            if (!conditionSucceeded)
                parser.parse(arguments[0]);
            conditionSucceeded = !conditionSucceeded;
        } else if (method == "execute") {
            parser.parse(utils.join(arguments));
        } else if (method == "author") {
            gametype.author = AUTHOR
                    + S_COLOR_ORANGE + " (map by " + S_COLOR_WHITE
                    + utils.join(arguments) + S_COLOR_ORANGE + ")";
        } else if (method == "goal") {
            objectiveSet.setGoal(ResultSet(arguments));
        } else {
            return Processor::process(method, arguments);
        }
        return true;
    }

    Processor @subProcessor(String target) {
        Objective @objective = objectiveSet.find(target);
        if (@objective != null)
            return objective;
        if (target == "players")
            return players;
        return Processor::subProcessor(target);
    }
}
