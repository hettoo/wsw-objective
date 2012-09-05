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
    String id;

    VariablesListener@[] listeners;

    Variable(String id, String@[] values) {
        this.id = id;
        set(values);
    }

    Variable(String id) {
        this.id = id;
        String@[] nothing;
        set(nothing);
    }

    String getId() {
        return id;
    }

    void addListener(VariablesListener @listener) {
        listeners.insertLast(listener);
    }

    void updated() {
        for (uint i = 0; i < listeners.size(); i++)
            listeners[i].variableChanged(this);
    }

    void set(String@[] values) {
    }

    void equals(String@[] values) {
    }

    void nequals(String@[] values) {
    }

    String @getString() {
        return null;
    }

    bool process(String method, String@[] arguments) {
        if (method == "set")
            set(arguments);
        else if (method == "equals")
            equals(arguments);
        else if (method == "nequals")
            nequals(arguments);
        else
            return Processor::process(method, arguments);
        return true;
    }
}
