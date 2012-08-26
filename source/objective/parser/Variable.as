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

class Variable : Processor {
    Variable(String value) {
        set(value);
    }

    Variable() {
        set("");
    }

    void set(String value) {
    }

    void add(String value) {
    }

    void equals(String value) {
    }

    void nequals(String value) {
    }

    String @getString() {
        return "";
    }

    bool process(String method, String argument) {
        if (method == "set")
            set(argument);
        else if (method == "add")
            add(argument);
        else if (method == "equals")
            equals(argument);
        else if (method == "nequals")
            nequals(argument);
        else
            return false;
        return true;
    }

    bool process(String method, String@[] arguments) {
        if (process(method, utils.join(arguments)))
            return true;
        return Processor::process(method, arguments);
    }
}
