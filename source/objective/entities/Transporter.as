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
Vec3 TRANSPORTER_MINS(-24, -24, -24);
Vec3 TRANSPORTER_MAXS(24, 24, 40);

class Transporter {
    cEntity @ent;
    Player @owner;

    float removeTime;

    Transporter(Vec3 origin, Vec3 angles, Player @owner) {
        @this.owner = owner;
        spawn(origin, angles);
    }

    void spawn(Vec3 origin, Vec3 angles) {
        @ent = G_SpawnEntity("transporter");
        ent.type = ET_GENERIC;
        ent.modelindex = TRANSPORTER_MODEL.get();
        ent.origin = origin;
        ent.angles = angles;
        @ent.owner = owner.getEnt();
        Vec3 dir, dir2, dir3;
        angles.angleVectors(dir, dir2, dir3);
        ent.velocity = ent.owner.velocity
                + dir * TRANSPORTER_THROW_SPEED;
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
        transporterSet.remove(this);
    }

    bool isActive() {
        return @ent != null;
    }

    void teleport() {
        ent.owner.teleportEffect(false);
        ent.owner.origin = ent.origin;
        ent.owner.velocity = ent.velocity;
        ent.owner.teleportEffect(true);
        remove();
    }

    void think() {
        removeTime -= frameTime * 0.001;
        if (removeTime <= 0)
            remove();
    }
}
