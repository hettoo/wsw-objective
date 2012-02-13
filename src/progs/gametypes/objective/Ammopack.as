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

cVec3 AMMOPACK_MINS(-24, -24, -16);
cVec3 AMMOPACK_MAXS(24, 24, 16);

const int AMMOPACK_RADIUS = 60;
const float AMMOPACK_WAIT_LIMIT = 16.0f;

class Ammopack {
    cEntity @ent;
    float removeTime;

    Players @players;

    Ammopack(cVec3 @origin, cVec3 @angles, cVec3 @velocity, cEntity @owner,
            Players @players, int model) {
        spawn(origin, angles, velocity, model);
        @ent.owner = owner;

        @this.players = players;
    }

    void spawn(cVec3 origin, cVec3 angles, cVec3 @velocity, int model) {
        @ent = G_SpawnEntity("ammopack");
        ent.type = ET_GENERIC;
        ent.modelindex = model;
        ent.setOrigin(origin);
        ent.setAngles(angles);
        ent.setVelocity(velocity);
        ent.setSize(AMMOPACK_MINS, AMMOPACK_MAXS);
        ent.solid = SOLID_NOT;
        ent.moveType = MOVETYPE_TOSS;
        ent.svflags &= ~SVF_NOCLIENT;
        ent.linkEntity();
        removeTime = AMMOPACK_WAIT_LIMIT;
    }

    void remove() {
        ent.unlinkEntity();
        ent.freeEntity();
        @ent = null;
    }

    bool near(cEntity @other) {
        return !other.isGhosting()
            && ent.getOrigin().distance(other.getOrigin()) <= AMMOPACK_RADIUS;
    }

    bool near(Player @player) {
        return near(player.getEnt());
    }

    void think() {
        if (@ent != null) {
            removeTime -= frameTime * 0.001;
            if (removeTime <= 0) {
                remove();
            } else {
                for (int i = 0; i < players.getSize(); i++) {
                    Player @player = players.get(i);
                    if (@player != null && near(player)
                            && player.giveAmmopack()) {
                        remove();
                        return;
                    }
                }
            }
        }
    }
}
