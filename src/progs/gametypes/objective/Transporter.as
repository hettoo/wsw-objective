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

const int TRANSPORTER_THROW_SPEED = 1100;
const float TRANSPORTER_WAIT_LIMIT = 16.0;

const Model TRANSPORTER_MODEL("objects/projectile/plasmagun/proj_plasmagun");
cVec3 TRANSPORTER_MINS(-24, -24, -24);
cVec3 TRANSPORTER_MAXS(24, 24, 40);

class Transporter {
    int id;

    cEntity @ent;

    float removeTime;

    TransporterSet @transporterSet;

    Transporter(cVec3 @origin, cVec3 @angles, cEntity @owner, int id,
            TransporterSet @transporterSet) {
        this.id = id;

        @this.transporterSet = transporterSet;

        spawn(origin, angles, owner);
    }

    void spawn(cVec3 @origin, cVec3 @angles, cEntity @owner) {
        @ent = G_SpawnEntity("transporter");
        ent.type = ET_GENERIC;
        ent.modelindex = TRANSPORTER_MODEL.get();
        ent.setOrigin(origin);
        ent.setAngles(angles);
        cVec3 dir;
        angles.angleVectors(dir, null, null);
        ent.setVelocity(owner.getVelocity() + dir * TRANSPORTER_THROW_SPEED);
        @ent.owner = owner;
        ent.setSize(TRANSPORTER_MINS, TRANSPORTER_MAXS);
        ent.solid = SOLID_NOT;
        ent.moveType = MOVETYPE_BOUNCEGRENADE;
        ent.svflags &= ~SVF_NOCLIENT;
        removeTime = TRANSPORTER_WAIT_LIMIT;
        ent.linkEntity();
    }

    void remove() {
        ent.unlinkEntity();
        ent.freeEntity();
        @ent = null;
        transporterSet.remove(id);
    }

    bool isActive() {
        return @ent != null;
    }

    void teleport() {
        ent.owner.teleportEffect(false);
        ent.owner.setOrigin(ent.getOrigin());
        ent.owner.setVelocity(ent.getVelocity());
        ent.owner.teleportEffect(true);
        remove();
    }

    void think() {
        removeTime -= frameTime * 0.001;
        if (removeTime <= 0)
            remove();
    }
}
