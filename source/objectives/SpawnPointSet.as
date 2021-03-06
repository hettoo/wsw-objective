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

class SpawnPointSet {
    cEntity@[] points;

    uint getSize() {
        return points.size();
    }

    cEntity @getRandom() {
        return points[brandom(0, points.size())];
    }

    void add(cEntity @ent) {
        points.insertLast(ent);
    }

    void analyze(String &name) {
        for (int i = 0; @G_GetEntity(i) != null; i++) {
            cEntity @ent = G_GetEntity(i);
            String target = ent.get_target();
            if (target.substr(0, 1) == OBJECTIVE_NAME_PREFIX
                    && target.substr(1, target.len()) == name) {
                add(ent);
            }
        }
    }
}
