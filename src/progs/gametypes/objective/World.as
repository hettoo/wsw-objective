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

    void initClient(cClient @client) {
        players.initClient(client);
    }

    void removeClient(cClient @client) {
        players.removeClient(client);
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

    void addAmmopack(cVec3 @origin, cVec3 @angles, cEntity @owner) {
        itemSet.addAmmopack(origin, angles, owner);
    }

    void addHealthpack(cVec3 @origin, cVec3 @angles, cEntity @owner) {
        itemSet.addHealthpack(origin, angles, owner);
    }

    void addBomb(cVec3 @origin, cVec3 @angles, cEntity @owner) {
        bombSet.add(origin, angles, owner);
    }

    void addClusterbomb(cVec3 @origin, cVec3 @angles, cEntity @owner) {
        clusterbombSet.add(origin, angles, owner);
    }

    void addArtillery(cVec3 @origin, cEntity @owner) {
        artillerySet.add(origin, owner);
    }

    Transporter @addTransporter(cVec3 @origin, cVec3 @angles, cEntity @owner) {
        return transporterSet.add(origin, angles, owner);
    }
}
