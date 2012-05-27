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

class SecureLocation : Component {
    bool occupied;

    SecureLocation(Objective @objective) {
        occupied = false;
        @this.objective = objective;
    }

    bool setAttribute(cString &name, cString &value) {
        if (name == "secureLocation") {
            active = value.toInt() == 1;
        } else {
            return false;
        }
        return true;
    }

    void thinkActive(Player @player) {
        if (occupied)
            return;

        Stealable @carry = player.getCarry();
        if (@carry == null)
            return;

        int newModel = carry.getObjective().getModel();
        if (player.secureCarry(objective)) {
            objective.setModel(newModel);
            objective.respawn();
            occupied = true;
        }
    }
}
