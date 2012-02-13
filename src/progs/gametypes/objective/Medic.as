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

const int HEALTH_ARMOR = 15;

class Medic : Class {
    Medic() {
        spawnHealth = 100;
        maxHealth = 120;

        spawnArmor = 50;
        maxArmor = 90;
    }

    cString @getName() {
        return "Medic";
    }

    bool giveAmmopack() {
        bool gaveClass = Class::giveAmmopack();
        bool gavePG = player.giveAmmo(WEAP_PLASMAGUN, 30, 80, 40, 120);
        bool gaveLG = player.giveAmmo(WEAP_LASERGUN, 30, 80, 20, 60);
        return gaveClass || gavePG || gaveLG;
    }

    void classAction1() {
        if (player.takeArmor(HEALTH_ARMOR)) {
            cVec3 origin, angles, velocity;
            cEntity @ent = player.getEnt();
            G_InitThrow(player.getEnt(), ITEM_THROW_SPEED,
                    origin, angles, velocity);
            player.getPlayers().getWorld().addHealthpack(
                    origin, angles, velocity, ent);
        } else {
            player.centerPrint(HEALTH_ARMOR
                    + " armor is required to drop health");
        }
    }

    // classaction2: revive
}
