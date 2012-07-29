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

const Model CLUSTERBOMB_MODEL("items/ammo/pack/pack");
Vec3 CLUSTERBOMB_MINS(-11, -11, -11);
Vec3 CLUSTERBOMB_MAXS(11, 11, 11);

const int CLUSTERBOMB_THROW_SPEED = 1000;
const int CLUSTERBOMB_EFFECT_RADIUS = 360;
const int CLUSTERBOMB_EFFECT = 130;
const float CLUSTERBOMB_TIME = 3.2f;

const int CB_NADES = 6;
const float CB_NADE_TIME = 1.6f;
const int CB_NADE_SPEED = 220;

const int CB_ROCKETS = 8;
const int CB_ROCKET_SPEED = 1000;

class Clusterbomb {
    int id;

    cEntity @ent;
    Player @owner;

    float timer;

    Clusterbomb(Vec3 @origin, Vec3 @angles, Player @owner, int id) {
        this.id = id;

        @this.owner = owner;

        spawn(origin, angles);
    }

    void spawn(Vec3 @origin, Vec3 @angles) {
        @ent = G_SpawnEntity("clusterbomb");
        ent.type = ET_GENERIC;
        ent.modelindex = CLUSTERBOMB_MODEL.get();
        ent.setOrigin(origin);
        ent.setAngles(angles);
        @ent.owner = owner.getEnt();
        Vec3 dir;
        angles.angleVectors(dir, null, null);
        ent.setVelocity(ent.owner.velocity + dir * CLUSTERBOMB_THROW_SPEED);
        ent.setSize(CLUSTERBOMB_MINS, CLUSTERBOMB_MAXS);
        ent.solid = SOLID_NOT;
        ent.moveType = MOVETYPE_BOUNCEGRENADE;
        ent.svflags &= ~SVF_NOCLIENT;
        ent.linkEntity();
        timer = CLUSTERBOMB_TIME;
    }

    void remove() {
        ent.unlinkEntity();
        ent.freeEntity();
        @ent = null;
        clusterbombSet.remove(id);
    }

    void releaseAmmo() {
        for (int i = 0; i < CB_NADES; i++) {
            Vec3 dir = Vec3(random() * 2 - 1, random() * 2 - 1, random());
            dir.toAngles(dir);
            cEntity @nade = G_FireGrenade(ent.origin, dir,
                    CB_NADE_SPEED / random(),
                    CLUSTERBOMB_EFFECT, CLUSTERBOMB_EFFECT, CLUSTERBOMB_EFFECT,
                    1, ent.owner);
            if (@nade != null)
                nade.nextThink = levelTime + CB_NADE_TIME * 1000;
        }
        for (int i = 0; i < CB_ROCKETS; i++) {
            Vec3 dir = Vec3(random() * 2 - 1, random() * 2 - 1, random());
            dir.toAngles(dir);
            G_FireRocket(ent.origin, dir,
                    CB_ROCKET_SPEED / random(),
                    CLUSTERBOMB_EFFECT, CLUSTERBOMB_EFFECT, CLUSTERBOMB_EFFECT,
                    1, ent.owner);
        }
    }

    void explode() {
        ent.explosionEffect(CLUSTERBOMB_EFFECT_RADIUS);
        ent.splashDamage(@ent.owner, CLUSTERBOMB_EFFECT_RADIUS,
                CLUSTERBOMB_EFFECT, CLUSTERBOMB_EFFECT, CLUSTERBOMB_EFFECT,
                MOD_EXPLOSIVE);
        releaseAmmo();
        remove();
    }

    void think() {
        timer -= frameTime * 0.001;
        if (timer <= 0)
            explode();
    }
}
