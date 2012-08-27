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

const int MAX_MINES = 5;

MineSet mineSet;

class MineSet {
    Mine@[] mineSet;
    int[] counts;

    MineSet() {
        counts.resize(GS_MAX_TEAMS);
        for (int i = 0; i < GS_MAX_TEAMS; i++)
            counts[i] = 0;
    }

    bool canAdd(Player @owner) {
        return counts[owner.getTeam()] < MAX_MINES;
    }

    bool add(Vec3 origin, Vec3 angles, Player @owner) {
        if (!canAdd(owner))
            return false;
        counts[owner.getTeam()]++;
        mineSet.insertLast(Mine(origin, angles, owner));
        return true;
    }

    bool remove(Mine @mine) {
        for (uint i = 0; i < mineSet.size(); i++) {
            if (@mineSet[i] == @mine) {
                mineSet.removeAt(i);
                counts[mine.getTeam()]--;
                return true;
            }
        }
        return false;
    }

    void think() {
        for (uint i = 0; i < mineSet.size(); i++)
            mineSet[i].think();
    }
}
