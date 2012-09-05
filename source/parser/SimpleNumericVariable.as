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

class SimpleNumericVariable : SingularVariable {
    SimpleNumericVariable(String id, String@[] values) {
        super(id, values);
    }

    SimpleNumericVariable(String id) {
        super(id);
    }

    void _or(String value) {
    }

    void _and(String value) {
    }

    void _xor(String value) {
    }

    bool process(String method, String argument) {
        if (method == "or")
            _or(argument);
        else if (method == "and")
            _and(argument);
        else if (method == "xor")
            _xor(argument);
        else
            return SingularVariable::process(method, argument);
        return true;
    }
}
