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

const String OBJECTIVE_NAME_PREFIX = "!";

ObjectiveSet objectiveSet;

class ObjectiveSet {
    Objective@[] objectiveSet;

    ResultSet @goal;
    bool suppressGoalTest;

    ObjectiveSet() {
        suppressGoalTest = false;
    }

    void add(cEntity @ent) {
        objectiveSet.insertLast(Objective(ent));
    }

    void analyze() {
        for (int i = 0; @G_GetEntity(i) != null; i++) {
            cEntity @ent = G_GetEntity(i);
            String targetname = ent.get_targetname();
            if (targetname.substr(0, 1) == OBJECTIVE_NAME_PREFIX)
                add(ent);
        }
    }

    Objective @find(String &id) {
        for (uint i = 0; i < objectiveSet.size(); i++) {
            if (objectiveSet[i].getId() == id)
                return @objectiveSet[i];
        }
        return null;
    }

    void setGoal(ResultSet @goal) {
        @this.goal = goal;
    }

    void goalTest() {
        if (suppressGoalTest || @goal == null || goal.isEmpty())
            return;

        Objective @objective;
        if (match.getState() <= MATCH_STATE_PLAYTIME && goal.done()) {
            G_GetTeam(TEAM_ALPHA).stats.addScore(1);
            match.launchState(match.getState() + 1);
        }
    }

    cEntity @randomSpawnPoint(cEntity @self) {
        int[] suitableSpawns;
        int suitableSpawnCount = 0;
        suitableSpawns.resize(objectiveSet.size());
        for (uint i = 0; i < objectiveSet.size(); i++) {
            if (objectiveSet[i].isSpawn() && objectiveSet[i].isSpawned()
                    && objectiveSet[i].getTeam() == self.team)
                suitableSpawns[suitableSpawnCount++] = i;
        }

        if (suitableSpawnCount == 0)
            return null;

        int spawnLocation = suitableSpawns[brandom(0, suitableSpawnCount)];
        return objectiveSet[spawnLocation].getRandomSpawnPoint();
    }

    void parse(String &filename) {
        String file = G_LoadFile(filename);
        Parser(StandardProcessor()).parse(file);
    }

    void initialSpawn() {
        suppressGoalTest = true;
        for (uint i = 0; i < objectiveSet.size(); i++)
            objectiveSet[i].initialSpawn();
        suppressGoalTest = false;
        goalTest();
    }

    void think() {
        for (uint i = 0; i < objectiveSet.size(); i++)
            objectiveSet[i].think();
    }

    void exploded(cEntity @ent, Player @planter) {
        suppressGoalTest = true;
        for (uint i = 0; i < objectiveSet.size(); i++)
            objectiveSet[i].exploded(ent, planter);
        suppressGoalTest = false;
        goalTest();
    }

    bool planted(cEntity @ent) {
        bool effective = false;
        for (uint i = 0; i < objectiveSet.size(); i++) {
            if (!effective)
                effective = objectiveSet[i].planted(ent);
        }
        return effective;
    }

    void defused(cEntity @ent, Player @defuser) {
        for (uint i = 0; i < objectiveSet.size(); i++)
            objectiveSet[i].defused(ent, defuser);
    }
}
