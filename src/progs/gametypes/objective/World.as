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

class World {
    Players players;
    ObjectiveSet objectiveSet;
    ItemSet itemSet;
    BombSet bombSet;
    ClusterbombSet clusterbombSet;
    ArtillerySet artillerySet;
    TransporterSet transporterSet;

    World() {
        players.register(this);
        itemSet.register(players);
        bombSet.register(players, objectiveSet);
    }

    Players @getPlayers() {
        return players;
    }

    ItemSet @getItemSet() {
        return itemSet;
    }

    BombSet @getBombSet() {
        return bombSet;
    }

    ClusterbombSet @getClusterbombSet() {
        return clusterbombSet;
    }

    ArtillerySet @getArtillerySet() {
        return artillerySet;
    }

    TransporterSet @getTransporterSet() {
        return transporterSet;
    }

    void spawn() {
        objectiveSet.register(players);
        objectiveSet.analyze();
        objectiveSet.parse("mapscripts/" + cVar("mapname", "", 0).getString()
                + ".cfg");
        objectiveSet.initialSpawn();
    }

    cEntity @selectSpawnPoint(cEntity @self) {
        return objectiveSet.randomSpawnPoint(self);
    }

    void think() {
        players.think();
        objectiveSet.think();
        itemSet.think();
        bombSet.think();
        clusterbombSet.think();
        artillerySet.think();
        transporterSet.think();
    }

    void newPlayer(cClient @client) {
        players.newPlayer(client);
    }

    void newSpectator(cClient @client) {
        players.newSpectator(client);
    }

    void respawnPlayer(cClient @client) {
        players.respawnPlayer(client);
    }
}
