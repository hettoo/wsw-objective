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

String@[] stack;

enum CacheType {
    CACHE_IMAGE,
    CACHE_MODEL,
    CACHE_SOUND
}

class StandardProcessor : Processor {
    Function@[] functions;

    bool conditionSucceeded;

    StringVariable @author;
    ArrayVariable @goal;

    StandardProcessor() {
        conditionSucceeded = false;

        @author = StringVariable("author");
        trackVariable(author);
        @goal = ArrayVariable("goal");
        trackVariable(goal);
    }

    void variableChanged(Variable @variable) {
        if (@variable == @author)
            gametype.author = AUTHOR
                    + S_COLOR_ORANGE + " (map by " + S_COLOR_WHITE
                    + author.get() + S_COLOR_ORANGE + ")";
        else if (@variable == @goal)
            objectiveSet.setGoal(ResultSet(goal.get()));
        else
            Processor::variableChanged(variable);
    }

    String popStack() {
        String result = stack[stack.size() - 1];
        stack.removeLast();
        return result;
    }

    bool checkCondition(String equation) {
        parser.parse(equation);
        conditionSucceeded = popStack().toInt() == 1;
        return conditionSucceeded;
    }

    bool process(String method, String@[] arguments) {
        if (method == "if") {
            if (checkCondition(arguments[0]))
                parser.parse(utils.join(arguments, 1));
        } else if (method == "elsif") {
            if (!conditionSucceeded && checkCondition(arguments[0]))
                parser.parse(utils.join(arguments, 1));
        } else if (method == "alsif") {
            if (conditionSucceeded && checkCondition(arguments[0]))
                parser.parse(utils.join(arguments, 1));
        } else if (method == "also") {
            if (conditionSucceeded)
                parser.parse(utils.join(arguments));
        } else if (method == "else") {
            if (!conditionSucceeded)
                parser.parse(utils.join(arguments));
            conditionSucceeded = !conditionSucceeded;
        } else if (method == "push") {
            stack.insertLast(utils.join(arguments));
        } else if (method == "execute") {
            parser.parse(utils.join(arguments));
        } else if (method == "include") {
            main.parse("includes/" + utils.join(arguments));
        } else {
            for (uint i = 0; i < functions.size(); i++) {
                if (functions[i].getId() == method) {
                    functions[i].execute(arguments);
                    return true;
                }
            }
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
        if (target == "function") {
            Function @function = Function(false);
            functions.insertLast(function);
            return function;
        }
        for (uint i = 0; i < functions.size(); i++) {
            if (functions[i].getId() == target)
                return functions[i];
        }
        return Processor::subProcessor(target);
    }

    String @getConstant(String name) {
        if (name == "pop")
            return popStack();

        String result;
        bool found = true;
        if (name == "CACHE_IMAGE")
            result = CACHE_IMAGE;
        else if (name == "CACHE_MODEL")
            result = CACHE_MODEL;
        else if (name == "CACHE_SOUND")
            result = CACHE_SOUND;
        else if (name == "TEAM_SPECTATOR")
            result = TEAM_SPECTATOR;
        else if (name == "TEAM_PLAYERS")
            result = TEAM_PLAYERS;
        else if (name == "TEAM_ALPHA")
            result = TEAM_ALPHA;
        else if (name == "TEAM_BETA")
            result = TEAM_BETA;
        else if (name == "GS_MAX_TEAMS")
            result = GS_MAX_TEAMS;
        else if (name == "MOVETYPE_NONE")
            result = MOVETYPE_NONE;
        else if (name == "MOVETYPE_PLAYER")
            result = MOVETYPE_PLAYER;
        else if (name == "MOVETYPE_NOCLIP")
            result = MOVETYPE_NOCLIP;
        else if (name == "MOVETYPE_PUSH")
            result = MOVETYPE_PUSH;
        else if (name == "MOVETYPE_STOP")
            result = MOVETYPE_STOP;
        else if (name == "MOVETYPE_FLY")
            result = MOVETYPE_FLY;
        else if (name == "MOVETYPE_TOSS")
            result = MOVETYPE_TOSS;
        else if (name == "MOVETYPE_LINEARPROJECTILE")
            result = MOVETYPE_LINEARPROJECTILE;
        else if (name == "MOVETYPE_BOUNCE")
            result = MOVETYPE_BOUNCE;
        else if (name == "MOVETYPE_BOUNCEGRENADE")
            result = MOVETYPE_BOUNCEGRENADE;
        else if (name == "MOVETYPE_TOSSSLIDE")
            result = MOVETYPE_TOSSSLIDE;
        else if (name == "SVF_NOCLIENT")
            result = SVF_NOCLIENT;
        else if (name == "SVF_PORTAL")
            result = SVF_PORTAL;
        else if (name == "SVF_TRANSMITORIGIN2")
            result = SVF_TRANSMITORIGIN2;
        else if (name == "SVF_SOUNDCULL")
            result = SVF_SOUNDCULL;
        else if (name == "SVF_FAKECLIENT")
            result = SVF_FAKECLIENT;
        else if (name == "SVF_BROADCAST")
            result = SVF_BROADCAST;
        else if (name == "SVF_CORPSE")
            result = SVF_CORPSE;
        else if (name == "SVF_PROJECTILE")
            result = SVF_PROJECTILE;
        else if (name == "SVF_ONLYTEAM")
            result = SVF_ONLYTEAM;
        else if (name == "SVF_FORCEOWNER")
            result = SVF_FORCEOWNER;
        else if (name == "SVF_ONLYOWNER")
            result = SVF_ONLYOWNER;
        else if (name == "SOLID_NOT")
            result = SOLID_NOT;
        else if (name == "SOLID_TRIGGER")
            result = SOLID_TRIGGER;
        else if (name == "SOLID_YES")
            result = SOLID_YES;
        else
            found = false;

        if (found)
            return result;
        else
            return Processor::getConstant(name);
    }
}
