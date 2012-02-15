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

cVec3 CLUSTERBOMB_MINS(-11, -11, -11);
cVec3 CLUSTERBOMB_MAXS(11, 11, 11);

const int CLUSTERBOMB_THROW_SPEED = 1000;
const int CLUSTERBOMB_EFFECT_RADIUS = 320;
const int CLUSTERBOMB_EFFECT = 120;
const float CLUSTERBOMB_TIME = 3.2f;

const int CB_NADES = 5;
const float CB_NADE_TIME = 1.4f;
const int CB_NADE_SPREAD = 1200;

class Clusterbomb {
    cEntity @ent;

    float timer;

    Clusterbomb(cVec3 @origin, cVec3 @angles, cEntity @owner, int model) {
        spawn(origin, angles, owner, model);
    }

    void spawn(cVec3 @origin, cVec3 @angles, cEntity @owner, int model) {
        @ent = G_SpawnEntity("clusterbomb");
        ent.type = ET_GENERIC;
        ent.modelindex = model;
        ent.setOrigin(origin);
        ent.setAngles(angles);
        cVec3 dir;
        angles.angleVectors(dir, null, null);
        ent.setVelocity(owner.getVelocity() + dir * CLUSTERBOMB_THROW_SPEED);
        @ent.owner = owner;
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
    }

    void releaseAmmo() {
        for (int i = 0; i < CB_NADES; i++) {
            cEntity @nade = G_FireGrenade(ent.getOrigin(),
                    CB_NADE_SPREAD * cVec3(random() * 2 - 1, random() * 2 - 1,
                        random()),
                    CLUSTERBOMB_EFFECT_RADIUS,
                    CLUSTERBOMB_EFFECT, CLUSTERBOMB_EFFECT, CLUSTERBOMB_EFFECT,
                    1, ent.owner);
            if (@nade != null)
                nade.nextThink = levelTime + CB_NADE_TIME * 1000;
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
        if (@ent == null)
            return;
        
        timer -= frameTime * 0.001;
        if (timer <= 0)
            explode();
    }
}
