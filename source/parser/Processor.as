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

class Processor : VariablesListener {
    Parser @parser;

    Dictionary variables;
    Variable@[] variableArray;
    Function@[] methods;

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
                parser.pushProcessor(subProcessor);
                targets.removeAt(0);
                bool result = subProcessor.process(targets, method, arguments);
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

    void addVariable(Variable @variable) {
        variables.set(variable.getId(), @variable);
        variableArray.insertLast(variable);
    }

    bool process(String method, String@[] arguments) {
        if (method == "define") {
            Variable @variable;
            String id = arguments[0];
            String@[] initial;
            initial.resize(arguments.size() - 2);
            for (uint i = 2; i < arguments.size(); i++)
                @initial[i - 2] = arguments[i];
            if (arguments[1] == "int")
                @variable = IntVariable(id, initial);
            else if (arguments[1] == "float")
                @variable = FloatVariable(id, initial);
            else if (arguments[1] == "string")
                @variable = StringVariable(id, initial);
            else if (arguments[1] == "array")
                @variable = ArrayVariable(id, initial);
            addVariable(variable);
        } else {
            for (uint i = 0; i < methods.size(); i++) {
                if (methods[i].getId() == method) {
                    methods[i].execute(arguments);
                    return true;
                }
            }
            for (uint i = 0; i < variableArray.size(); i++) {
                if (variableArray[i].getId() == method) {
                    variableArray[i].set(arguments);
                    return true;
                }
            }
            return false;
        }
        return true;
    }

    Processor @subProcessor(String target) {
        Variable @variable = getVariable(target);
        if (@variable != null)
            return variable;
        if (target == "method") {
            Function @method = Function(true);
            methods.insertLast(method);
            return method;
        }
        for (uint i = 0; i < methods.size(); i++) {
            if (methods[i].getId() == target)
                return methods[i];
        }
        return null;
    }
}
