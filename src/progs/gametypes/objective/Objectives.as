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

const cString OBJECTIVE_NAME_PREFIX = "!";

class Objectives {
    Objective@[] objectives;
    int size;
    int capacity;

    cString goal;

    Players @players;

    Objectives() {
        capacity = 0;
        size = 0;
    }

    void register(Players @players) {
        @this.players = players;
    }

    void makeRoom() {
        if (capacity == size) {
            capacity *= 2;
            capacity += 1;
            objectives.resize(capacity);
        }
    }

    void add(cEntity @ent) {
        makeRoom();
        @objectives[size++] = Objective(ent, this, players);
    }

    void analyze() {
        for (int i = 0; @G_GetEntity(i) != null; i++) {
            cEntity @ent = G_GetEntity(i);
            cString targetname = ent.getTargetnameString();
            if (targetname.substr(0, 1) == OBJECTIVE_NAME_PREFIX)
                add(ent);
        }
    }

    Objective @find(cString &id) {
        for (int i = 0; i < size; i++) {
            if (objectives[i].getId() == id)
                return @objectives[i];
        }
        return null;
    }

    void goalTest() {
        if (goal == "")
            return;

        Objective @objective;
        bool inverse = false;
        if (goal.substr(0, 1) == "~") {
            @objective = find(goal.substr(1, goal.len()));
            inverse = true;
        } else {
            @objective = find(goal);
        }
        if (objective.isSpawned() ^^ inverse
                && match.getState() == MATCH_STATE_PLAYTIME) {
            G_GetTeam(TEAM_ASSAULT).stats.addScore(1);
            match.launchState(match.getState() + 1);
        }
    }

    void setAttribute(cString &fieldname, cString &value) {
        if (fieldname == "goal")
            goal = value;
    }

    void parse(cString &filename) {
        cString file = G_LoadFile(filename);
        Objective @objective;
        cString fieldname;
        bool stop = false;
        int i = 0;
        do {
            cString token = file.getToken(i);
            if (token.substr(0, 1) == OBJECTIVE_NAME_PREFIX) {
                @objective = find(token.substr(1, token.len()));
            } else if (fieldname == "") {
                fieldname = token;
                if (fieldname == "")
                    stop = true;
            } else {
                if (@objective == null)
                    setAttribute(fieldname, token);
                else
                    objective.setAttribute(fieldname, token);
                fieldname = "";
            }
            i++;
        } while (!stop);
    }

    void initialSpawn() {
        for (int i = 0; i < size; i++)
            objectives[i].initialSpawn();
    }

    void think() {
        for (int i = 0; i < size; i++)
            objectives[i].think();
    }

    void exploded(cEntity @ent) {
        for (int i = 0; i < size; i++)
            objectives[i].exploded(ent);
        goalTest();
    }

    void planted(cEntity @ent) {
        for (int i = 0; i < size; i++)
            objectives[i].planted(ent);
    }

    void defused(cEntity @ent) {
        for (int i = 0; i < size; i++)
            objectives[i].defused(ent);
    }
}
