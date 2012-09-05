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
    Objective @objective;
    cEntity @ent;

    StringVariable @id;
    IntVariable @model;
    IntVariable @solid;
    ArrayVariable @offset;
    ArrayVariable @angles;
    ArrayVariable @mins;
    ArrayVariable @maxs;
    IntVariable @moveType;
    IntVariable @svFlags;
    IntVariable @clipMask;
    FloatVariable @radius;

    ObjectiveEntity(Objective @objective) {
        @id = StringVariable("id");
        addVariable(id);
        @model = IntVariable("model");
        addVariable(model);
        @solid = IntVariable("solid");
        solid.set(SOLID_YES);
        addVariable(solid);
        String@[] defaultOffset;
        for (int i = 0; i < 3; i++)
            defaultOffset.insertLast("0");
        @offset = ArrayVariable("offset", defaultOffset);
        addVariable(offset);
        String@[] defaultAngles;
        for (int i = 0; i < 3; i++)
            defaultAngles.insertLast("0");
        @angles = ArrayVariable("angles", defaultAngles);
        addVariable(angles);
        String@[] defaultMins;
        for (int i = 0; i < 3; i++)
            defaultMins.insertLast("0");
        @mins = ArrayVariable("mins", defaultMins);
        addVariable(mins);
        String@[] defaultMaxs;
        for (int i = 0; i < 3; i++)
            defaultMaxs.insertLast("0");
        @maxs = ArrayVariable("maxs", defaultMaxs);
        addVariable(maxs);
        @moveType = IntVariable("moveType");
        moveType.set(MOVETYPE_NONE);
        addVariable(moveType);
        @svFlags = IntVariable("svFlags");
        addVariable(svFlags);
        @clipMask = IntVariable("clipMask");
        clipMask.set(MASK_PLAYERSOLID);
        addVariable(clipMask);
        @radius = FloatVariable("radius");
        addVariable(radius);

        setObjective(objective);
    }

    void setObjective(Objective @objective) {
        @this.objective = objective;
        setAngles(objective.getAngles());
        radius.set(objective.getRadius());
    }

    String @getId() {
        return id.get();
    }

    void setId(String id) {
        this.id.set(id);
    }

    void setSolid(int solid) {
        this.solid.set(solid);
    }

    void setModel(const Model @model) {
        this.model.set(model.get());
    }

    int getMoveType() {
        return moveType.get();
    }

    void setMoveType(int moveType) {
        this.moveType.set(moveType);
    }

    void setSVFlags(int svFlags) {
        this.svFlags.set(svFlags);
    }

    void setOffset(Vec3 offset) {
        this.offset.set(utils.writeVec3(offset));
    }

    void setAngles(Vec3 angles) {
        this.angles.set(utils.writeVec3(angles));
    }

    void setMins(Vec3 mins) {
        this.mins.set(utils.writeVec3(mins));
    }

    void setMaxs(Vec3 maxs) {
        this.maxs.set(utils.writeVec3(maxs));
    }

    void setRadius(float radius) {
        this.radius.set(radius);
    }

    bool process(String method, String@[] arguments) {
        if (method == "destroy")
            destroy();
        else
            return Processor::process(method, arguments);
        return true;
    }

    void spawn(Vec3 baseOrigin) {
        int model = this.model.get();
        if (model != 0) {
            @ent = G_SpawnEntity("objective");
            ent.type = ET_GENERIC;
            ent.modelindex = model;
            ent.team = objective.getOwningTeam();
            ent.origin = baseOrigin + utils.readVec3(offset.get());
            ent.angles = utils.readVec3(angles.get());
            ent.setSize(utils.readVec3(mins.get()), utils.readVec3(maxs.get()));
            ent.solid = solid.get();
            ent.clipMask = clipMask.get();
            ent.moveType = moveType.get();
            ent.svflags = svFlags.get();
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
        return utils.near(@ent == null ? objective.getOrigin()
                + utils.readVec3(offset.get())
                : ent.origin, other.origin, radius.get());
    }
}
