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

const int MAX_ARTILLERIES = 2;

ArtillerySet artillerySet;

class ArtillerySet {
    Artillery@[] artillerySet;
    int[] counts;

    ArtillerySet() {
        counts.resize(GS_MAX_TEAMS);
        for (int i = 0; i < GS_MAX_TEAMS; i++)
            counts[i] = 0;
    }

    bool canAdd(Player @owner) {
        return counts[owner.getTeam()] < MAX_ARTILLERIES;
    }

    bool add(Vec3 origin, Player @owner) {
        if (!canAdd(owner))
            return false;
        counts[owner.getTeam()]++;
        artillerySet.insertLast(Artillery(origin, owner));
        return true;
    }

    bool remove(Artillery @artillery) {
        for (uint i = 0; i < artillerySet.size(); i++) {
            if (@artillerySet[i] == @artillery) {
                artillerySet.removeAt(i);
                counts[artillery.getTeam()]--;
                return true;
            }
        }
        return false;
    }

    void think() {
        for (uint i = 0; i < artillerySet.size(); i++)
            artillerySet[i].think();
    }
}
