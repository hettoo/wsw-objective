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

enum ResultMethod {
    RM_SPAWN,
    RM_DESTROY,
    RM_SECURE,
    RM_LOCK
}

class Result {
    int method;
    Objective @objective;

    Result(String &target) {
        method = RM_SPAWN;
        String methodString = target.substr(0, 1);
        if (methodString == "~")
            method = RM_DESTROY;
        else if (methodString == "@")
            method = RM_SECURE;
        else if (methodString == "*")
            method = RM_LOCK;

        @objective = objectiveSet.find(target.substr(method == RM_SPAWN ? 0 : 1,
                    target.len()));
    }

    String @getName() {
        return objective.getName();
    }

    Objective @getObjective() {
        return objective;
    }

    void apply(int team) {
        switch (method) {
            case RM_SPAWN:
                objective.spawn(team);
                break;
            case RM_DESTROY:
                objective.destroy();
                break;
            case RM_LOCK:
                objective.lock(team);
                break;
        }
    }

    void apply() {
        switch (method) {
            case RM_SPAWN:
                objective.spawn();
                break;
            case RM_DESTROY:
                objective.destroy();
                break;
            case RM_LOCK:
                objective.lock();
                break;
        }
    }

    bool done() {
        switch (method) {
            case RM_SPAWN:
                return objective.isSpawned();
            case RM_DESTROY:
                return !objective.isSpawned();
            case RM_SECURE:
                return objective.isSecured();
        }
        return false;
    }
}
