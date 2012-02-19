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

const int BOMB_ARMOR = 60;

class Engineer : Class {
    Engineer() {
        spawnArmor = 40;
        maxArmor = 90;

        primaryWeapon = WEAP_RIOTGUN;
        primaryStrongSpawnAmmo = 8;
        primaryStrongAmmo = 4;
        primaryStrongMaxAmmo = 10;
        primaryWeakSpawnAmmo = 10;
        primaryWeakAmmo = 5;
        primaryWeakMaxAmmo = 12;

        secondaryWeapon = WEAP_LASERGUN;
        secondaryStrongSpawnAmmo = 40;
        secondaryStrongAmmo = 30;
        secondaryStrongMaxAmmo = 80;
        secondaryWeakSpawnAmmo = 60;
        secondaryWeakAmmo = 40;
        secondaryWeakMaxAmmo = 100;
    }

    cString @getName() {
        return "Engineer";
    }

    void classAction1(Player @player) {
        cVec3 origin, angles;
        cEntity @ent = player.getEnt();
        if (!G_CheckInitThrow(player.getEnt(), origin, angles,
                    BOMB_MINS, BOMB_MAXS)) {
            player.centerPrint("Can't spawn a bomb there");
        } else if (!player.takeArmor(BOMB_ARMOR)) {
            player.centerPrint(BOMB_ARMOR
                    + " armor is required to throw a bomb");
        } else {
            player.getPlayers().getWorld().addBomb(origin, angles, ent);
        }
    }

    // classaction2: shoot a grenade far away?
    // create a turret (perhaps it might only be activated if a teammember is
    // standing next to it)?
    // spawn a(n invisible) landmine?
}
