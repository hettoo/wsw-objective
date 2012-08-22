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

    Callback @code;
    String@[] arguments;

    String @getId() {
        return id;
    }

    Variable @getVariable(String name) {
        if (name.isNumeric())
            return StringVariable(arguments[name.toInt() - 1]);
        return Processor::getVariable(name);
    }

    bool process(String method, String@[] arguments) {
        if (method == "id") {
            id = arguments[0];
        } else if (method == "code") {
            @code = parser.createCallback(arguments[0]);
        } else {
            return Processor::process(method, arguments);
        }
        return true;
    }

    void execute(String@[] arguments) {
        this.arguments = arguments;
        parser.executeCallback(code);
    }
}
