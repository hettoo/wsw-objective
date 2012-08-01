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

Core objective;

void GT_SpawnGametype() {
    objective.spawnGametype();
}

void GT_InitGametype() {
    objective.initGametype();
}

bool GT_Command(cClient @client, String &cmd, String &args, int argc) {
    return objective.command(client, cmd, args, argc);
}

cEntity @GT_SelectSpawnPoint(cEntity @self) {
    return objective.selectSpawnPoint(self);
}

void GT_playerRespawn(cEntity @ent, int oldTeam, int newTeam) {
    objective.playerRespawn(ent, oldTeam, newTeam);
}

bool GT_UpdateBotStatus(cEntity @self) {
    return objective.updateBotStatus(self);
}

void GT_scoreEvent(cClient @client, String &scoreEvent, String &args) {
    objective.scoreEvent(client, scoreEvent, args);
}

void GT_ThinkRules() {
    objective.thinkRules();
}

void GT_MatchStateStarted() {
    objective.matchStateStarted();
}

bool GT_MatchStateFinished(int newMatchState) {
    return objective.matchStateFinished(newMatchState);
}

String @GT_ScoreboardMessage(uint maxlen) {
    return objective.scoreboardMessage(maxlen);
}

void GT_Shutdown() {
    objective.shutdown();
}
