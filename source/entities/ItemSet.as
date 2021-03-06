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

const Model AMMOPACK_MODEL("items/ammo/ammobox/ammobox");
Vec3 AMMOPACK_MINS(-11, -11, -11);
Vec3 AMMOPACK_MAXS(11, 11, 11);

const Model HEALTHPACK_MODEL("items/health/small/small_health");
Vec3 HEALTHPACK_MINS(-11, -11, -11);
Vec3 HEALTHPACK_MAXS(11, 11, 11);

const Sound HEALTHPACK_SOUND("items/item_spawn");
const Sound AMMOPACK_SOUND("items/item_spawn");

enum Items {
    ITEM_HEALTHPACK,
    ITEM_AMMOPACK
}

ItemSet itemSet;

class ItemSet {
    Item@[] itemSet;

    void addHealthpack(Vec3 origin, Vec3 angles, Player @owner) {
        itemSet.insertLast(Item(origin, angles, owner,
                    HEALTHPACK_MODEL.get(), HEALTHPACK_SOUND.get(),
                    HEALTHPACK_MINS, HEALTHPACK_MAXS, ITEM_HEALTHPACK));
    }

    void addAmmopack(Vec3 origin, Vec3 angles, Player @owner) {
        itemSet.insertLast(Item(origin, angles, owner,
                    AMMOPACK_MODEL.get(), AMMOPACK_SOUND.get(),
                AMMOPACK_MINS, AMMOPACK_MAXS, ITEM_AMMOPACK));
    }

    bool remove(Item @item) {
        for (uint i = 0; i < itemSet.size(); i++) {
            if (@itemSet[i] == @item) {
                itemSet.removeAt(i);
                return true;
            }
        }
        return false;
    }

    void think() {
        for (uint i = 0; i < itemSet.size(); i++)
            itemSet[i].think();
    }
}
