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
    int solid;
    int model;
    Vec3 offset;
    Vec3 angles;
    Vec3 mins;
    Vec3 maxs;
    int moveType;
    int svFlags;
    float radius;

    ObjectiveEntity(Objective @objective) {
        setObjective(objective);
        solid = SOLID_YES;
        model = 0;
        moveType = MOVETYPE_NONE;
        svFlags = 0;
    }

    void setObjective(Objective @objective) {
        @this.objective = objective;
        this.angles = objective.getAngles();
        radius = objective.getRadius();
    }

    String @getId() {
        return id;
    }

    void setId(String id) {
        this.id = id;
    }

    void setSolid(int solid) {
        this.solid = solid;
    }

    void setModel(const Model @model) {
        this.model = model.get();
    }

    int getMoveType() {
        return moveType;
    }

    void setMoveType(int moveType) {
        this.moveType = moveType;
    }

    void setSVFlags(int svFlags) {
        this.svFlags = svFlags;
    }

    void setOffset(Vec3 offset) {
        this.offset = offset;
    }

    void setAngles(Vec3 angles) {
        this.angles = angles;
    }

    void setMins(Vec3 mins) {
        this.mins = mins;
    }

    void setMaxs(Vec3 maxs) {
        this.maxs = maxs;
    }

    void setRadius(float radius) {
        this.radius = radius;
    }

    bool process(String method, String@[] arguments) {
        if (method == "id")
            setId(utils.join(arguments));
        else if (method == "solid")
            setSolid(arguments[0].toInt());
        else if (method == "model")
            setModel(Model(utils.join(arguments)));
        else if (method == "moveType")
            setMoveType(arguments[0].toInt());
        else if (method == "svFlags")
            setSVFlags(arguments[0].toInt());
        else if (method == "offset")
            setOffset(utils.readVec3(arguments));
        else if (method == "angles")
            setAngles(utils.readVec3(arguments));
        else if (method == "mins")
            setMins(utils.readVec3(arguments));
        else if (method == "maxs")
            setMaxs(utils.readVec3(arguments));
        else if (method == "radius")
            setRadius(arguments[0].toFloat());
        else if (method == "destroy")
            destroy();
        else
            return Processor::process(method, arguments);
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
            ent.solid = solid;
            ent.clipMask = MASK_PLAYERSOLID;
            ent.moveType = moveType;
            ent.svflags = svFlags;
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
}
