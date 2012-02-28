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

class ResultSet : Set {
    bool empty;
    Result@[] resultSet;
    ObjectiveSet @objectiveSet;

    ResultSet(cString &targets, ObjectiveSet @objectiveSet) {
        empty = true;

        @this.objectiveSet = objectiveSet;

        analyze(targets);
    }

    void analyze(cString &targets) {
        cString target;
        for (int i = 0; i < targets.len(); i++) {
            cString current = targets.substr(i, 1);
            if (current == ",") {
                add(target);
                target = "";
            } else {
                target += current;
            }
        }
        add(target);
    }

    void resize() {
        resultSet.resize(capacity);
    }

    void add(cString &target) {
        makeRoom();
        @resultSet[size++] = Result(target, objectiveSet);
        empty = false;
    }

    bool isEmpty() {
        return empty;
    }

    bool contains(Objective @objective) {
        for (int i = 0; i < size; i++) {
            if (@resultSet[i].getObjective() == @objective)
                return true;
        }
        return false;
    }

    cString @getName() {
        return resultSet[0].getName();
    }

    void apply(int team) {
        for (int i = 0; i < size; i++)
            resultSet[i].apply(team);
    }

    void apply() {
        for (int i = 0; i < size; i++)
            resultSet[i].apply();
    }

    bool done() {
        for (int i = 0; i < size; i++) {
            if (!resultSet[i].done())
                return false;
        }
        return true;
    }
}
