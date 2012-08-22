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
    Function@[] functions;

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
                targets.removeAt(0);
                bool result = subProcessor.process(targets, method, arguments);
                subProcessor.stopProcessor();
                return result;
            }
        }
        return false;
    }

    Variable @getVariable(String name) {
        Variable @variable;
        variables.get(name, @variable);
        return variable;
    }

    String @preProcess(String argument, bool bracketed, bool isMethod) {
        if (bracketed || argument.length() == 0 || argument.substr(0, 1) != "#")
            return null;
        Variable @variable = getVariable(argument.substr(1));
        if (@variable == null)
            return null;
        return variable.getString();
    }

    bool process(String method, String@[] arguments) {
        if (method == "define") {
            Variable @variable;
            if (arguments[1] == "int")
                @variable = IntVariable();
            else if (arguments[1] == "float")
                @variable = FloatVariable();
            else if (arguments[1] == "string")
                @variable = StringVariable();
            variables.set(arguments[0], @variable);
        } else if (method == "set") {
            Variable @variable = getVariable(arguments[0]);
            if (@variable == null)
                return false;
            variable.set(utils.join(1, arguments));
        } else if (method == "add") {
            Variable @variable = getVariable(arguments[0]);
            if (@variable == null)
                return false;
            variable.add(utils.join(1, arguments));
        } else if (method == "multiply") {
            Variable @variable = getVariable(arguments[0]);
            if (@variable == null)
                return false;
            variable.multiply(utils.join(1, arguments));
        } else {
            for (uint i = 0; i < functions.size(); i++) {
                if (functions[i].getId() == method) {
                    functions[i].execute(arguments);
                    return true;
                }
            }
            return false;
        }
        return true;
    }

    Processor @subProcessor(String target) {
        if (target == "function") {
            Function @function = Function();
            functions.insertLast(function);
            return function;
        }
        return null;
    }
}
