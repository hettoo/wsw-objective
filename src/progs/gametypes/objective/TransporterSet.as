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

TransporterSet transporterSet;

class TransporterSet : Set {
    Transporter@[] transporterSet;

    void resize() {
        transporterSet.resize(capacity);
    }

    Transporter @add(Vec3 @origin, Vec3 @angles, Player @owner) {
        int id = UNKNOWN;
        for (int i = 0; i < size && id == UNKNOWN; i++) {
            if (@transporterSet[i] == null)
                id = i;
        }
        if (id == UNKNOWN) {
            makeRoom();
            id = size++;
        }
        @transporterSet[id] = Transporter(origin, angles, owner, id);
        return transporterSet[id];
    }

    void remove(int n) {
        @transporterSet[n] = null;
    }

    void think() {
        for (int i = 0; i < size; i++) {
            if (@transporterSet[i] != null)
                transporterSet[i].think();
        }
    }
}
