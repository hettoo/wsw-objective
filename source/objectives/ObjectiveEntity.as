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

class ObjectiveEntity : Processor {
    String id;

    Objective @objective;
    cEntity @ent;
    bool solid;
    int model;
    Vec3 offset;
    Vec3 angles;
    Vec3 mins;
    Vec3 maxs;
    int moveType;
    float radius;

    ObjectiveEntity(Objective @objective) {
        @this.objective = objective;
        this.angles = objective.getAngles();
        radius = objective.getRadius();

        solid = true;
        model = 0;
        moveType = MOVETYPE_NONE;
    }

    String @getId() {
        return id;
    }

    bool process(String method, String@[] arguments) {
        if (method == "id") {
            id = utils.join(arguments);
        } else if (method == "solid") {
            solid = arguments[0].toInt() == 1;
        } else if (method == "model") {
            model = Model(utils.join(arguments)).get();
        } else if (method == "moveType") {
            moveType = arguments[0].toInt();
        } else if (method == "offset") {
            offset = Vec3(arguments[0].toFloat(), arguments[1].toFloat(),
                    arguments[2].toFloat());
        } else if (method == "angles") {
            angles = Vec3(arguments[0].toFloat(), arguments[1].toFloat(),
                    arguments[2].toFloat());
        } else if (method == "mins") {
            mins = Vec3(arguments[0].toFloat(), arguments[1].toFloat(),
                    arguments[2].toFloat());
        } else if (method == "maxs") {
            maxs = Vec3(arguments[0].toFloat(), arguments[1].toFloat(),
                    arguments[2].toFloat());
        } else if (method == "radius") {
            radius = arguments[0].toInt();
        } else if (method == "spawn") {
            spawn();
        } else {
            return Processor::process(method, arguments);
        }
        return true;
    }

    void spawn(Vec3 baseOrigin) {
        if (model != 0) {
            @ent = G_SpawnEntity("objective");
            ent.type = ET_GENERIC;
            ent.modelindex = model;
            ent.team = objective.getOwningTeam();
            ent.origin = baseOrigin + offset;
            ent.angles = angles;
            ent.setSize(mins, maxs);
            ent.solid = solid ? SOLID_YES : SOLID_NOT;
            ent.clipMask = MASK_PLAYERSOLID;
            ent.moveType = moveType;
            ent.svflags &= ~SVF_NOCLIENT;
            ent.linkEntity();
        }
    }

    void spawn() {
        spawn(objective.getOrigin());
    }

    void destroy() {
        if (@ent != null) {
            ent.unlinkEntity();
            ent.freeEntity();
            @ent = null;
        }
    }

    bool near(cEntity @other) {
        return utils.near(@ent == null ? objective.getOrigin() + offset
                : ent.origin, other.origin, radius);
    }

    int getModel() {
        return model;
    }

    void setModel(int model) {
        this.model = model;
    }

    int getMoveType() {
        return moveType;
    }

    void setMoveType(int moveType) {
        this.moveType = moveType;
    }

    void setEnt(cEntity @ent) {
        @this.ent = ent;
    }
}
