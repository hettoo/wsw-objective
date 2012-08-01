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

const int ITEM_RADIUS = 36;
const float ITEM_WAIT_LIMIT = 20.0f;

const int ITEM_THROW_SPEED = 400;
const int ITEM_SCORE = 1;

class Item {
    int id;

    cEntity @ent;
    int type;
    Player @owner;

    float removeTime;

    Item(Vec3 origin, Vec3 angles, Player @owner, int id,
            int model, int sound, Vec3 mins, Vec3 maxs, int type) {
        this.id = id;
        this.type = type;
        @this.owner = owner;

        spawn(origin, angles, model, sound, mins, maxs);
    }

    void spawn(Vec3 origin, Vec3 angles, int model, int sound,
            Vec3 mins, Vec3 maxs) {
        @ent = G_SpawnEntity("item");
        ent.type = ET_GENERIC;
        ent.modelindex = model;
        ent.origin = origin;
        ent.angles = angles;
        @ent.owner = owner.getEnt();
        Vec3 dir, dir2, dir3;
        angles.angleVectors(dir, dir2, dir3);
        ent.velocity = ent.owner.velocity + dir * ITEM_THROW_SPEED;
        ent.setSize(mins, maxs);
        ent.solid = SOLID_NOT;
        ent.moveType = MOVETYPE_TOSS;
        ent.svflags &= ~SVF_NOCLIENT;
        ent.linkEntity();
        removeTime = ITEM_WAIT_LIMIT;
        G_Sound(ent, CHAN_ITEM, sound, ATTN_ITEM_SPAWN);
    }

    void remove() {
        ent.unlinkEntity();
        ent.freeEntity();
        @ent = null;
        itemSet.remove(id);
    }

    bool near(cEntity @other) {
        return G_Near(ent, other, ITEM_RADIUS);
    }

    bool near(Player @player) {
        return near(player.getEnt());
    }

    void think() {
        removeTime -= frameTime * 0.001;
        if (removeTime <= 0) {
            remove();
            return;
        }

        for (int i = 0; i < players.getSize(); i++) {
            Player @player = players.get(i);
            if (@player != null && near(player)) {
                if ((type == ITEM_HEALTHPACK && player.giveHealthpack())
                        || (type == ITEM_AMMOPACK && player.giveAmmopack())) {
                    if (player.getClient().team == owner.getClient().team
                            && @player != @owner)
                        owner.addScore(ITEM_SCORE);
                    remove();
                    return;
                }
            }
        }
    }
}
