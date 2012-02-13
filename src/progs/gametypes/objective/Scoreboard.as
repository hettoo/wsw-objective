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

class Scoreboard {
    int noIcon;
    int yesIcon;

    World @world;

    Scoreboard() {
        noIcon = G_ImageIndex("gfx/hud/icons/vsay/no");
        yesIcon = G_ImageIndex("gfx/hud/icons/vsay/yes");
    }

    void register(World @world) {
        @this.world = world;
    }

    cString @scoreboardPlayer(cTeam @team, int entId, int maxLen) {
        cEntity @ent = team.ent(entId);
        cClient @client = ent.client;
        Player @player = world.getPlayers().get(client.playerNum());
        int readyIcon = noIcon;

        if (client.isReady())
            readyIcon = yesIcon;

        int playerId = (ent.isGhosting()
                && (match.getState() == MATCH_STATE_PLAYTIME))
            ? -(ent.playerNum() + 1) : ent.playerNum();

        cString entry = "&p " + playerId + " " + client.getClanName() + " "
            + client.stats.score + " " + client.ping + " "
            + player.getClassIcon() + " " + readyIcon + " ";

        if (entry.len() <= maxLen)
            return entry;
        return "";
    }

    cString @scoreboardTeam(int teamId, int maxLen) {
            cTeam @team = G_GetTeam(teamId);

            cString message = "";
            cString entry = "&t " + teamId + " " + team.stats.score + " "
                + team.ping + " ";

            if (entry.len() <= maxLen) {
                message += entry;
                for (int j = 0; @team.ent(j) != null; j++)
                    message +=scoreboardPlayer(team, j, maxLen - message.len());
            }

            return message;
    }

    cString @createMessage(int maxLen) {
        cString message = "";
        message += scoreboardTeam(TEAM_ASSAULT, maxLen - message.len());
        message += scoreboardTeam(TEAM_DEFENSE, maxLen - message.len());
        return message;
    }
}