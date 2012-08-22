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

class Component : Processor {
    bool active;

    Objective @objective;

    Component(Objective @objective) {
        active = false;
        @this.objective = objective;
    }

    void startProcessor() {
        active = true;
    }

    bool process(String method, String@[] arguments) {
        if (method == "active") {
            active = arguments[0].toInt() == 1;
            return true;
        }
        return Processor::process(method, arguments);
    }

    bool isActive() {
        return active;
    }

    Objective @getObjective() {
        return objective;
    }

    void thinkActive() {
    }

    void think() {
        if (active)
            thinkActive();
    }

    void thinkActive(Player @player) {
    }

    void think(Player @player) {
        if (active && player.isAlive() && player.getTeam() != TEAM_SPECTATOR)
            thinkActive(player);
    }
}
