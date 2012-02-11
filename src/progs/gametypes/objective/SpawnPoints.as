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

class SpawnPoints {
    cEntity@[] points;
    int size;
    int capacity;

    SpawnPoints() {
        capacity = 0;
        size = 0;
    }

    void makeRoom() {
        if (capacity == size) {
            capacity *= 2;
            capacity += 1;
            points.resize(capacity);
        }
    }

    int getSize() {
        return size;
    }

    cEntity @getRandom() {
        return points[brandom(0, size)];
    }

    void add(cEntity @ent) {
        makeRoom();
        @points[size++] = ent;
    }

    void analyze(cString &name) {
        for (int i = 0; @G_GetEntity(i) != null; i++) {
            cEntity @ent = G_GetEntity(i);
            cString target = ent.getTargetString();
            if (target.substr(0, 1) == OBJECTIVE_NAME_PREFIX
                    && target.substr(1, target.len()) == name) {
                add(ent);
            }
        }
    }
}