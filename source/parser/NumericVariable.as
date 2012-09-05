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

class NumericVariable : SimpleNumericVariable {
    NumericVariable(String id, String@[] values) {
        super(id, values);
    }

    NumericVariable(String id) {
        super(id);
    }

    void add(String value) {
    }

    void multiply(String value) {
    }

    void modulo(String value) {
    }

    bool process(String method, String argument) {
        if (method == "add")
            add(argument);
        else if (method == "multiply")
            multiply(argument);
        else if (method == "modulo")
            modulo(argument);
        else
            return SimpleNumericVariable::process(method, argument);
        return true;
    }
}
