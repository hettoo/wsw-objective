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

const Sound CAPTURE_SOUND("announcer/objective/captured");

class Spawnable : Component {
    bool capturable;

    SpawnPointSet @spawnPointSet;

    Objective @objective;

    Spawnable(Objective @objective) {
        capturable = false;

        @this.objective = objective;
    }

    bool isActive() {
        return Component::isActive() && spawnPointSet.getSize() > 0;
    }

    bool setAttribute(cString &name, cString &value) {
        if (name == "spawnLocation") {
            active = value.toInt() == 1;
            @spawnPointSet = SpawnPointSet();
            spawnPointSet.analyze(objective.getId());
        } else if (name == "capturable") {
            capturable = value.toInt() == 1;
        } else {
            return false;
        }
        return true;
    }

    cEntity @getRandomSpawnPoint() {
        return spawnPointSet.getRandom();
    }

    void thinkActive(Player @player) {
        int playerTeam = player.getClient().team;
        if (capturable && objective.getTeam() != playerTeam) {
            objective.setTeam(playerTeam);
            Players @players = objective.getPlayers();
            if (objective.getName() != "")
                players.say(G_GetTeamName(playerTeam)
                        + " has captured " + objective.getName() + "!");
            players.sound(CAPTURE_SOUND.get());
        }
    }
}
