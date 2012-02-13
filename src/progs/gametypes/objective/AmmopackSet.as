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

class AmmopackSet {
    Ammopack@[] ammopackSet;
    int size;
    int capacity;

    int ammopackModel;

    Players @players;

    AmmopackSet() {
        capacity = 0;
        size = 0;

        ammopackModel = G_ModelIndex("models/objects/misc/ammobox.md3");
    }

    void register(Players @players) {
        @this.players = players;
    }

    void makeRoom() {
        if (capacity == size) {
            capacity *= 2;
            capacity += 1;
            ammopackSet.resize(capacity);
        }
    }

    void add(cVec3 @origin, cVec3 @angles, cVec3 @velocity, cEntity @owner) {
        makeRoom();
        @ammopackSet[size++] = Ammopack(origin, angles, velocity, owner,
                players, ammopackModel);
    }

    void think() {
        for (int i = 0; i < size; i++)
            ammopackSet[i].think();
    }
}
