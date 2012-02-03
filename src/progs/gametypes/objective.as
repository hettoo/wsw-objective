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

Map objective;

void GT_SpawnGametype() {
    objective.spawnGametype();
}

void GT_InitGametype() {
    objective.initGametype();
}

bool GT_Command(cClient @client, cString &cmd, cString &args, int argc) {
    return objective.command(client, cmd, args, argc);
}

bool GT_UpdateBotStatus(cEntity @self) {
    return objective.updateBotStatus(self);
}

cEntity @GT_SelectSpawnPoint(cEntity @self) {
    return objective.selectSpawnPoint(self);
}

cString @GT_ScoreboardMessage(int maxlen) {
    return objective.scoreboardMessage(maxlen);
}

void GT_scoreEvent(cClient @client, cString &score_event, cString &args) {
    objective.scoreEvent(client, score_event, args);
}

void GT_playerRespawn(cEntity @ent, int old_team, int new_team) {
    objective.playerRespawn(ent, old_team, new_team);
}

void GT_ThinkRules() {
    objective.thinkRules();
}

void GT_MatchStateStarted() {
    objective.matchStateStarted();
}

bool GT_MatchStateFinished(int new_match_state) {
    return objective.matchStateFinished(new_match_state);
}

void GT_Shutdown() {
    objective.shutdown();
}
