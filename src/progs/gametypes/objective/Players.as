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

Players players;

class Players {
    Player@[] players;
    int size;

    Players() {
        players.resize(maxClients);
    }

    Player @get(int id) {
        return players[id];
    }

    Player @get(cClient @client) {
        if (@client == null)
            return null;
        return get(client.playerNum);
    }

    Classes @getClasses() {
        return classes;
    }

    int getSize() {
        return size;
    }

    void initClient(cClient @client) {
        int id = client.playerNum;
        Player @player = get(id);
        if (@player == null) {
            @players[id] = Player();
            if (id >= size)
                size = id + 1;
            @player = players[id];
        }
        player.init(client);
    }

    void remove(int id) {
        @players[id] = null;
    }

    void reset() {
        for (int i = 0; i < size; i++) {
            if (@players[i] != null)
                players[i].setScore(0);
        }
    }

    void removeClient(cClient @client) {
        remove(client.playerNum);
    }

    void newPlayer(cClient @client) {
        get(client).syncScore();
    }

    void newSpectator(cClient @client) {
    }

    void respawnPlayer(cClient @client) {
        get(client).spawn();
    }

    void madeKill(Player @player, String &args) {
        cEntity @target = G_GetEntity(args.getToken(0).toInt());
        if (@target != null && @target.client != null) {
            if (@player != null)
                player.madeKill(@target == @player.getEnt(),
                        target.client.team == player.getClient().team);
            get(target.client).killed();
        }
    }

    void think() {
        for (int i = 0; i < size; i++) {
            if (@players[i] != null)
                players[i].think();
        }
    }

    int otherTeam(int team) {
        if (team == TEAM_ALPHA)
            return TEAM_BETA;
        return TEAM_ALPHA;
    }

    void say(String &message) {
        G_PrintMsg(null, message + "\n");
    }

    void sound(int sound) {
        G_GlobalSound(CHAN_VOICE, sound);
    }

    int soundIndex(String sound) {
        return Sound(sound).get();
    }

    void sound(String &sound) {
        sound(soundIndex(sound));
    }

    void sound(int team, int sound) {
        G_AnnouncerSound(null, sound, team, true, null);
    }
}
