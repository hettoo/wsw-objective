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

class SingularVariable : Variable {
    SingularVariable(String id, String@[] values) {
        super(id, values);
    }

    SingularVariable(String id) {
        super(id);
    }

    void set(String value) {
    }

    void equals(String value) {
    }

    void nequals(String value) {
    }

    void set(String@[] values) {
        set(utils.join(values));
    }

    void equals(String@[] values) {
        equals(utils.join(values));
    }

    void nequals(String@[] values) {
        nequals(utils.join(values));
    }

    bool process(String method, String argument) {
        return false;
    }

    bool process(String method, String@[] arguments) {
        if (process(method, utils.join(arguments)))
            return true;
        return Variable::process(method, arguments);
    }
}
