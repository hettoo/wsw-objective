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

class FieldOps : Class {
    FieldOps() {
        spawnHealth = 100;
        spawnArmor = 40;

        maxHealth = 100;
        maxArmor = 80;
    }

    cString @getName() {
        return "Field Ops";
    }

    cString @getSimpleName() {
        return "field_ops";
    }

    void giveAmmoPack() {
        Class::giveAmmoPack();

        player.giveAmmo(WEAP_ROCKETLAUNCHER, 8, 20, 10, 30);
        player.giveAmmo(WEAP_PLASMAGUN, 30, 80, 40, 120);
    }
}
