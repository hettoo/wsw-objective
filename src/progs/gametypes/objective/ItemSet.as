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

cVec3 AMMOPACK_MINS(-11, -11, -11);
cVec3 AMMOPACK_MAXS(11, 11, 11);

cVec3 HEALTHPACK_MINS(-11, -11, -11);
cVec3 HEALTHPACK_MAXS(11, 11, 11);

enum Items {
    ITEM_HEALTHPACK,
    ITEM_AMMOPACK
}

class ItemSet : Set {
    Item@[] itemSet;

    int healthpackModel;
    int ammopackModel;

    int healthpackSound;
    int ammopackSound;

    Players @players;

    ItemSet() {
        healthpackSound = G_SoundIndex("sounds/items/item_spawn");
        ammopackSound = G_SoundIndex("sounds/items/item_spawn");

        healthpackModel
            = G_ModelIndex("models/items/health/small/small_health.md3");
        ammopackModel = G_ModelIndex("models/items/ammo/ammobox/ammobox.md3");
    }

    void register(Players @players) {
        @this.players = players;
    }

    void resize() {
        itemSet.resize(capacity);
    }

    int getNextId() {
        int id = UNKNOWN;
        for (int i = 0; i < size && id == UNKNOWN; i++) {
            if (@itemSet[i] == null)
                id = i;
        }
        if (id == UNKNOWN) {
            makeRoom();
            id = size++;
        }
        return id;
    }

    void addHealthpack(cVec3 @origin, cVec3 @angles, cEntity @owner) {
        int id = getNextId();
        @itemSet[id] = Item(origin, angles, owner, id, this, players,
                healthpackModel, healthpackSound,
                HEALTHPACK_MINS, HEALTHPACK_MAXS, ITEM_HEALTHPACK);
    }

    void addAmmopack(cVec3 @origin, cVec3 @angles, cEntity @owner) {
        int id = getNextId();
        @itemSet[id] = Item(origin, angles, owner, id, this, players,
                ammopackModel, ammopackSound,
                AMMOPACK_MINS, AMMOPACK_MAXS, ITEM_AMMOPACK);
    }

    void remove(int n) {
        @itemSet[n] = null;
    }

    void think() {
        for (int i = 0; i < size; i++) {
            if (@itemSet[i] != null)
                itemSet[i].think();
        }
    }
}
