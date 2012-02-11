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

class Players {
    Player@[] players;
    int size;

    World @world;

    Players() {
        players.resize(maxClients);
    }

    void register(World @world) {
        @this.world = world;
    }

    Player @get(int id) {
        return players[id];
    }

    Player @get(cClient @client) {
        return get(client.playerNum());
    }

    World @getWorld() {
        return world;
    }

    int getSize() {
        return size;
    }

    void initClient(cClient @client) {
        int id = client.playerNum();
        Player @player = get(id);
        if (@player == null) {
            @players[id] = Player(this);
            if (id >= size)
                size = id + 1;
            @player = players[id];
        }
        player.init(client);
    }

    void remove(int id) {
        @players[id] = null;
    }

    void removeClient(cClient @client) {
        remove(client.playerNum());
    }

    void newPlayer(cClient @client) {
    }

    void newSpectator(cClient @client) {
    }

    void respawnPlayer(cClient @client) {
        get(client).spawn();
    }

    void think() {
        for (int i = 0; i < size; i++) {
            if (@players[i] != null)
                players[i].think();
        }
    }

    int otherTeam(int team) {
        if (team == TEAM_ASSAULT)
            return TEAM_DEFENSE;
        return TEAM_ASSAULT;
    }

    void say(cString &message) {
        G_PrintMsg(null, message + "\n");
    }

    void sound(cString &sound) {
        G_GlobalSound(CHAN_VOICE, G_SoundIndex("sounds/" + sound));
    }

    void sound(int team, cString &sound) {
        G_AnnouncerSound(null, G_SoundIndex("sounds/" + sound), team, true,
                null);
    }
}