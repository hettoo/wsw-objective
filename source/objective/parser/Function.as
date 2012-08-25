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

class Function : Processor {
    String id;

    bool macro;
    String @code;
    Callback @callback;
    String@[] arguments;

    Function() {
        macro = false;
    }

    String @getId() {
        return id;
    }

    Variable @getVariable(String name) {
        if (name.isNumeric())
            return StringVariable(arguments[name.toInt() - 1]);
        if (name == "@")
            return StringVariable(utils.join(arguments));
        if (name.substr(0, 1) == "-") {
            String index = name.substr(1);
            if (index.isNumeric())
                return StringVariable(arguments[arguments.size()
                        - index.toInt()]);
        }
        return Processor::getVariable(name);
    }

    bool process(String method, String@[] arguments) {
        if (method == "id") {
            id = arguments[0];
        } else if (method == "macro") {
            macro = arguments[0].toInt() == 1;
        } else if (method == "code") {
            @code = arguments[0];
            @callback = parser.createCallback(code);
        } else {
            return Processor::process(method, arguments);
        }
        return true;
    }

    void execute(String@[] arguments) {
        this.arguments = arguments;
        if (macro)
            parser.parse(code);
        else
            parser.executeCallback(callback);
    }
}
