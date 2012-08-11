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

class ResultSet {
    Result@[] resultSet;

    ResultSet(String@[] targets) {
        analyze(targets);
    }

    void analyze(String@[] targets) {
        String target;
        for (uint i = 0; i < targets.size(); i++)
            add(targets[i]);
    }

    void add(String &target) {
        resultSet.insertLast(Result(target));
    }

    bool isEmpty() {
        return resultSet.empty();
    }

    bool contains(Objective @objective) {
        for (uint i = 0; i < resultSet.size(); i++) {
            if (@resultSet[i].getObjective() == @objective)
                return true;
        }
        return false;
    }

    bool done() {
        for (uint i = 0; i < resultSet.size(); i++) {
            if (!resultSet[i].done())
                return false;
        }
        return true;
    }
}
