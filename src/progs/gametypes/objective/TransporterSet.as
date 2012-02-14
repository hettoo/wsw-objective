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

class TransporterSet : Set {
    Transporter@[] transporterSet;

    int transporterModel;

    void resize() {
        transporterSet.resize(capacity);

        transporterModel = G_ModelIndex("models/items/ammo/pack/pack.md3");
    }

    Transporter @add(cVec3 @origin, cVec3 @angles, cVec3 @velocity,
            cEntity @owner) {
        makeRoom();
        Transporter @new = Transporter(origin, angles, velocity, owner,
                transporterModel);
        @transporterSet[size++] = new;
        return new;
    }
}
