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
    Objectives objectives;
    Bombs bombs;

    World() {
        players.register(this);
        bombs.register(players, objectives);
    }

    Players @getPlayers() {
        return players;
    }

    void spawn() {
        objectives.register(players);
        objectives.analyze();
        objectives.parse("mapscripts/" + cVar("mapname", "", 0).getString()
                + ".obj");
        objectives.initialSpawn();
    }

    void think() {
        players.think();
        objectives.think();
        bombs.think();
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

    void addBomb(cVec3 @origin, cVec3 @angles, cVec3 @velocity,
            cEntity @owner) {
        bombs.add(origin, angles, velocity, owner);
    }
}
