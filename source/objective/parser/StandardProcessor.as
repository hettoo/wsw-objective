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

    Variable @getVariable(String name) {
        if (name == "TEAM_SPECTATOR")
            return IntVariable(TEAM_SPECTATOR);
        if (name == "TEAM_PLAYERS")
            return IntVariable(TEAM_PLAYERS);
        if (name == "TEAM_ALPHA")
            return IntVariable(TEAM_ALPHA);
        if (name == "TEAM_BETA")
            return IntVariable(TEAM_BETA);
        if (name == "GS_MAX_TEAMS")
            return IntVariable(GS_MAX_TEAMS);

        if (name == "MOVETYPE_NONE")
            return IntVariable(MOVETYPE_NONE);
        if (name == "MOVETYPE_PLAYER")
            return IntVariable(MOVETYPE_PLAYER);
        if (name == "MOVETYPE_NOCLIP")
            return IntVariable(MOVETYPE_NOCLIP);
        if (name == "MOVETYPE_PUSH")
            return IntVariable(MOVETYPE_PUSH);
        if (name == "MOVETYPE_STOP")
            return IntVariable(MOVETYPE_STOP);
        if (name == "MOVETYPE_FLY")
            return IntVariable(MOVETYPE_FLY);
        if (name == "MOVETYPE_TOSS")
            return IntVariable(MOVETYPE_TOSS);
        if (name == "MOVETYPE_LINEARPROJECTILE")
            return IntVariable(MOVETYPE_LINEARPROJECTILE);
        if (name == "MOVETYPE_BOUNCE")
            return IntVariable(MOVETYPE_BOUNCE);
        if (name == "MOVETYPE_BOUNCEGRENADE")
            return IntVariable(MOVETYPE_BOUNCEGRENADE);
        if (name == "MOVETYPE_TOSSSLIDE")
            return IntVariable(MOVETYPE_TOSSSLIDE);

        if (name == "SVF_NOCLIENT")
            return IntVariable(SVF_NOCLIENT);
        if (name == "SVF_PORTAL")
            return IntVariable(SVF_PORTAL);
        if (name == "SVF_TRANSMITORIGIN2")
            return IntVariable(SVF_TRANSMITORIGIN2);
        if (name == "SVF_SOUNDCULL")
            return IntVariable(SVF_SOUNDCULL);
        if (name == "SVF_FAKECLIENT")
            return IntVariable(SVF_FAKECLIENT);
        if (name == "SVF_BROADCAST")
            return IntVariable(SVF_BROADCAST);
        if (name == "SVF_CORPSE")
            return IntVariable(SVF_CORPSE);
        if (name == "SVF_PROJECTILE")
            return IntVariable(SVF_PROJECTILE);
        if (name == "SVF_ONLYTEAM")
            return IntVariable(SVF_ONLYTEAM);
        if (name == "SVF_FORCEOWNER")
            return IntVariable(SVF_FORCEOWNER);

        if (name == "SOLID_NOT")
            return IntVariable(SOLID_NOT);
        if (name == "SOLID_TRIGGER")
            return IntVariable(SOLID_TRIGGER);
        if (name == "SOLID_YES")
            return IntVariable(SOLID_YES);

        return Processor::getVariable(name);
    }
}
