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
    cVec3 origin;
    cVec3 mins;
    cVec3 maxs;
    cString id;
    bool spawned;
    cEntity @ent;

    cString model;
    bool start;
    int team;

    bool constructable;
    cString constructing;
    cString constructed;

    bool destroyable;
    cString destroyed;

    cString message;

    Objective(cEntity @ent) {
        origin = ent.getOrigin();
        id = ent.getTargetnameString();
        id = id.substr(1, id.len());
        spawned = false;

        model = "";
        start = true;
        team = GS_MAX_TEAMS;

        constructable = false;
        destroyable = false;

        ent.unlinkEntity();
        ent.freeEntity();
    }

    cString @getId() {
        return id;
    }

    void setAttribute(cString &name, cString &value) {
        if (name == "start") {
            start = value.toInt() == 1;
        } else if (name == "model") {
            model = value;
        } else if (name == "mins") {
            mins = cVec3(value.getToken(0).toFloat(),
                    value.getToken(1).toFloat(), value.getToken(2).toFloat());
        } else if (name == "maxs") {
            maxs = cVec3(value.getToken(0).toFloat(),
                    value.getToken(1).toFloat(), value.getToken(2).toFloat());
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

    void spawn() {
        @ent = G_SpawnEntity("objective");
        ent.type = ET_GENERIC;
        ent.modelindex = G_ModelIndex("models/" + model + ".md3");
        ent.modelindex2 = ent.modelindex;
        ent.team = team;
        ent.setOrigin(origin);
        ent.setSize(mins, maxs);
        ent.solid = SOLID_YES;
        ent.clipMask = MASK_PLAYERSOLID;
        ent.moveType = MOVETYPE_TOSS;
        ent.svflags &= ~SVF_NOCLIENT;
        ent.linkEntity();
    }

    void initialSpawn() {
        if (start) {
            spawn();
        }
    }

    void think() {
    }
}
