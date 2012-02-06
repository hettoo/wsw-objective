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

class Core {
    void spawnGametype() {
    }

    void initGametype() {
    }

    bool command(cClient @client, cString &cmd, cString &args, int argc) {
        return true;
    }

    cEntity @selectSpawnPoint(cEntity @self) {
        return null;
    }

    void playerRespawn(cEntity @ent, int oldTeam, int newTeam) {
    }

    bool updateBotStatus(cEntity @self) {
        return true;
    }

    void scoreEvent(cClient @client, cString &scoreEvent, cString &args) {
    }

    void thinkRules() {
    }

    void matchStateStarted() {
    }

    bool matchStateFinished(int newMatchState) {
        return true;
    }

    cString @scoreboardMessage(int maxLen) {
        return "";
    }

    void shutdown() {
    }
}
