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

const int ITEM_RADIUS = 24;
const float ITEM_WAIT_LIMIT = 16.0f;

const int ITEM_THROW_SPEED = 400;

class Item {
    cEntity @ent;
    int type;

    float removeTime;

    Players @players;

    Item(cVec3 @origin, cVec3 @angles, cVec3 @velocity, cEntity @owner,
            Players @players, int model, cVec3 @mins, cVec3 @maxs, int type) {
        this.type = type;
        spawn(origin, angles, velocity, model, mins, maxs);
        @ent.owner = owner;

        @this.players = players;
    }

    void spawn(cVec3 origin, cVec3 angles, cVec3 @velocity, int model,
            cVec3 @mins, cVec3 @maxs) {
        @ent = G_SpawnEntity("item");
        ent.type = ET_GENERIC;
        ent.modelindex = model;
        ent.setOrigin(origin);
        ent.setAngles(angles);
        ent.setVelocity(velocity);
        ent.setSize(mins, maxs);
        ent.solid = SOLID_NOT;
        ent.moveType = MOVETYPE_TOSS;
        ent.svflags &= ~SVF_NOCLIENT;
        ent.linkEntity();
        removeTime = ITEM_WAIT_LIMIT;
    }

    void remove() {
        ent.unlinkEntity();
        ent.freeEntity();
        @ent = null;
    }

    bool near(cEntity @other) {
        return !other.isGhosting()
            && ent.getOrigin().distance(other.getOrigin()) <= ITEM_RADIUS;
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
                    if (@player != null && near(player)) {
                        if ((type == ITEM_HEALTHPACK && player.giveHealthpack())
                                || (type == ITEM_AMMOPACK
                                    && player.giveAmmopack())) {
                            remove();
                            return;
                        }
                    }
                }
            }
        }
    }
}