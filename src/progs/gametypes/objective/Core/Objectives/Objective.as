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

class Objective {
    cEntity @ent;
    cString id;

    cString model;
    bool linked;
    int team;

    bool constructable;
    cString constructing;
    cString constructed;

    bool destroyable;
    cString destroyed;

    cString message;

    Objective(cEntity @ent) {
        @this.ent = ent;
        id = ent.getTargetnameString();
        id = id.substr(1, id.len());

        model = "";
        linked = true;
        team = GS_MAX_TEAMS;

        constructable = false;
        destroyable = false;
    }

    cString @getId() {
        return id;
    }

    void setAttribute(cString &name, cString &value) {
        if (name == "linked") {
            linked = value.toInt() == 1;
        } else if (name == "model") {
            model = value;
        } else if (name == "team") {
            if (value == "ASSAULT")
                team = TEAM_ASSAULT;
            else if (value == "DEFENSE")
                team = TEAM_DEFENSE;
        } else if (name == "constructable") {
            constructable = value.toInt() == 1;
        } else if (name == "constructing") {
            constructing = value;
        } else if (name == "constructed") {
            constructed = value;
        } else if (name == "destroyable") {
            destroyable = value.toInt() == 1;
        } else if (name == "destroyed") {
            destroyed = value;
        } else if (name == "message") {
            message = value;
        }
    }

    void think() {
    }
}
