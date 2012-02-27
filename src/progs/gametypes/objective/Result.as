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

class Result {
    bool destroy;
    Objective @objective;

    ObjectiveSet @objectiveSet;

    Result(cString &target, ObjectiveSet @objectiveSet) {
        destroy = target.substr(0, 1) == "~";
        @objective = objectiveSet.find(target.substr(destroy ? 1 : 0,
                    target.len()));

        @this.objectiveSet = objectiveSet;
    }

    cString @getName() {
        return objective.getName();
    }

    void apply(int team) {
        if (destroy)
            objective.destroy();
        else
            objective.spawn(team);
    }

    void apply() {
        if (destroy)
            objective.destroy();
        else
            objective.spawn();
    }

    bool done() {
        return destroy ^^ objective.isSpawned();
    }
}
