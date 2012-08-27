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

void GT_SpawnGametype() {
    main.spawnGametype();
}

void GT_InitGametype() {
    main.initGametype();
}

bool GT_Command(cClient @client, String &cmd, String &args, int argc) {
    return main.command(client, cmd, args, argc);
}

cEntity @GT_SelectSpawnPoint(cEntity @self) {
    return main.selectSpawnPoint(self);
}

void GT_playerRespawn(cEntity @ent, int oldTeam, int newTeam) {
    main.playerRespawn(ent, oldTeam, newTeam);
}

bool GT_UpdateBotStatus(cEntity @self) {
    return main.updateBotStatus(self);
}

void GT_scoreEvent(cClient @client, String &scoreEvent, String &args) {
    main.scoreEvent(client, scoreEvent, args);
}

void GT_ThinkRules() {
    main.thinkRules();
}

void GT_MatchStateStarted() {
    main.matchStateStarted();
}

bool GT_MatchStateFinished(int newMatchState) {
    return main.matchStateFinished(newMatchState);
}

String @GT_ScoreboardMessage(uint maxlen) {
    return main.scoreboardMessage(maxlen);
}

void GT_Shutdown() {
    main.shutdown();
}
