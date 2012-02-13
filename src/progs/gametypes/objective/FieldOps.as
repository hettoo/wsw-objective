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

const int AMMOPACK_ARMOR = 20;

class FieldOps : Class {
    FieldOps() {
        spawnArmor = 50;
        maxArmor = 90;
    }

    cString @getName() {
        return "Field Ops";
    }

    bool giveAmmopack() {
        bool gaveClass = Class::giveAmmopack();
        bool gaveRL = player.giveAmmo(WEAP_ROCKETLAUNCHER, 8, 20, 10, 30);
        bool gavePG = player.giveAmmo(WEAP_PLASMAGUN, 30, 80, 40, 120);
        return gaveClass || gaveRL || gavePG;
    }

    void classAction1() {
        if (player.takeArmor(AMMOPACK_ARMOR)) {
            cVec3 origin, angles, velocity;
            cEntity @ent = player.getEnt();
            G_InitThrow(player.getEnt(), ITEM_THROW_SPEED,
                    origin, angles, velocity);
            player.getPlayers().getWorld().addAmmopack(origin, angles, velocity,
                    ent);
        } else {
            player.centerPrint(AMMOPACK_ARMOR
                    + " armor is required to throw an ammopack");
        }
    }

    // classaction2: clusterbomb
}
