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

const Model CARRY_IDENTICATOR_MODEL("objects/misc/bomb_centered");
Vec3 CARRY_IDENTICATOR_OFFSET(0, 0, 64);
const float INDICATOR_PREDICTION_MULTIPLIER = 0.02;

class CarryIdenticator {
    cEntity @ent;
    cEntity @identicator;

    CarryIdenticator(cEntity @ent) {
        @this.ent = ent;

        @identicator = G_SpawnEntity("carry_identicator");
        identicator.type = ET_GENERIC;
        identicator.modelindex = CARRY_IDENTICATOR_MODEL.get();
        identicator.solid = SOLID_NOT;
        identicator.moveType = MOVETYPE_NONE;
        identicator.svflags &= ~SVF_NOCLIENT;
        identicator.linkEntity();
        update();
    }

    void update() {
        identicator.origin = ent.origin + CARRY_IDENTICATOR_OFFSET
            + INDICATOR_PREDICTION_MULTIPLIER * ent.get_velocity();
        identicator.angles = Vec3(0, ent.angles.y, 0);
        identicator.velocity = ent.velocity;
    }

    void destroy() {
        identicator.unlinkEntity();
        identicator.freeEntity();
        @identicator = null;
    }
}
