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

class Processor {
    Parser @parser;

    Dictionary variables;

    void startProcessor() {
    }

    void stopProcessor() {
    }

    void setParser(Parser @parser) {
        @this.parser = parser;
    }

    bool process(String@[] targets, String method, String@[] arguments) {
        if (targets.size() == 0) {
            return process(method, arguments);
        } else {
            Processor @subProcessor = subProcessor(targets[0]);
            if (@subProcessor != null) {
                subProcessor.startProcessor();
                parser.pushProcessor(subProcessor);
                targets.removeAt(0);
                bool result = subProcessor.process(targets, method, arguments);
                subProcessor.stopProcessor();
                parser.popProcessor();
                return result;
            }
        }
        return false;
    }

    String @getConstant(String name) {
        return null;
    }

    Variable @getVariable(String name) {
        Variable @variable;
        variables.get(name, @variable);
        return variable;
    }

    String @preProcess(String argument, bool bracketed, bool isMethod) {
        if (bracketed || argument.length() == 0 || argument.substr(0, 1) != "#")
            return null;
        String name = argument.substr(1);
        String @constant = getConstant(name);
        if (@constant != null)
            return constant;
        Variable @variable = getVariable(name);
        if (@variable == null)
            return null;
        return variable.getString();
    }

    bool process(String method, String@[] arguments) {
        if (method == "define") {
            Variable @variable;
            String initial = utils.join(2, arguments);
            if (arguments[1] == "int")
                @variable = IntVariable(initial);
            else if (arguments[1] == "float")
                @variable = FloatVariable(initial);
            else if (arguments[1] == "string")
                @variable = StringVariable(initial);
            variables.set(arguments[0], @variable);
        } else {
            return false;
        }
        return true;
    }

    Processor @subProcessor(String target) {
        Variable @variable = getVariable(target);
        if (@variable != null)
            return variable;
        return null;
    }
}
