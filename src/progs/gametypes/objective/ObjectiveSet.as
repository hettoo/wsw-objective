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

class ObjectiveSet : Set {
    Objective@[] objectiveSet;

    cString goal;

    Players @players;

    void register(Players @players) {
        @this.players = players;
    }

    void resize() {
        objectiveSet.resize(capacity);
    }

    void add(cEntity @ent) {
        makeRoom();
        @objectiveSet[size++] = Objective(ent, this, players);
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
            if (objectiveSet[i].getId() == id)
                return @objectiveSet[i];
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

    cEntity @randomSpawnPoint(cEntity @self) {
        int[] suitableSpawns;
        int suitableSpawnCount = 0;
        suitableSpawns.resize(size);
        for (int i = 0; i < size; i++) {
            if (objectiveSet[i].isSpawn()
                    && objectiveSet[i].getTeam() == self.team)
                suitableSpawns[suitableSpawnCount++] = i;
        }

        if (suitableSpawnCount == 0)
            return null;

        int spawnLocation = suitableSpawns[brandom(0, suitableSpawnCount)];
        return objectiveSet[spawnLocation].getRandomSpawnPoint();
    }

    void setAttribute(cString &fieldname, cString &value) {
        if (fieldname == "author")
            gametype.setAuthor(gametype.getAuthor()
                    + S_COLOR_ORANGE + " (map by " + S_COLOR_WHITE + value
                    + S_COLOR_ORANGE + ")");
        else if (fieldname == "goal")
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
            objectiveSet[i].initialSpawn();
    }

    void think() {
        for (int i = 0; i < size; i++)
            objectiveSet[i].think();
    }

    void exploded(cEntity @ent, Player @planter) {
        for (int i = 0; i < size; i++)
            objectiveSet[i].exploded(ent, planter);
        goalTest();
    }

    bool planted(cEntity @ent) {
        bool effective = false;
        for (int i = 0; i < size; i++) {
            if (!effective)
                effective = objectiveSet[i].planted(ent);
        }
        return effective;
    }

    void defused(cEntity @ent, Player @defuser) {
        for (int i = 0; i < size; i++)
            objectiveSet[i].defused(ent, defuser);
    }
}
