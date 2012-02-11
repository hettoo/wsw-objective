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

class Destroyable {
    bool active;
    cString destroyed;

    int destroyIcon;

    Objective @objective;

    Destroyable() {
        active = false;

        destroyIcon = G_ImageIndex("gfx/bomb/carriericon");
    }

    void register(Objective @objective) {
        @this.objective = objective;
    }

    bool isActive() {
        return active;
    }

    bool setAttribute(cString &name, cString &value) {
        if (name == "destroyable")
            active = value.toInt() == 1;
        else if (name == "destroyed")
            destroyed = value;
        else
            return false;
        return true;
    }

    void destruct() {
        objective.destroy();

        objective.getPlayers().say(objective.message);

        if (destroyed != "")
            objective.getObjectives().find(destroyed).spawn();
    }

    void think() {
        if (!active)
            return;

        int players = objective.getPlayers().getSize();
        for (int i = 0; i < players; i++) {
            Player @player = objective.getPlayers().get(i);
            if (@player != null && objective.nearOtherTeam(player))
                player.setHUDStat(STAT_IMAGE_OTHER, destroyIcon);
        }
    }
}
