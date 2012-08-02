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
        primarySpawnAmmo = 10;
        primaryAmmo = 5;
        primaryMaxAmmo = 18;

        secondaryWeapon = WEAP_LASERGUN;
        secondarySpawnAmmo = 40;
        secondaryAmmo = 30;
        secondaryMaxAmmo = 80;
    }

    String @getName() {
        return "Engineer";
    }

    void classAction1(Player @player) {
        cEntity @ent = player.getEnt();
        Vec3 origin = G_ThrowOrigin(ent);
        Vec3 angles = G_ThrowAngles(ent);
        if (!G_CanSpawn(origin, BOMB_MINS, BOMB_MAXS, ent.entNum)) {
            player.centerPrint("Can't spawn a bomb there");
        } else if (!player.takeArmor(BOMB_ARMOR)) {
            player.centerPrint(BOMB_ARMOR
                    + " armor is required to throw a bomb");
        } else {
            bombSet.add(origin, angles, player);
        }
    }

    // classaction2: shoot a grenade far away?
    // create a turret (perhaps it might only be activated if a teammember is
    // standing next to it)?
    // spawn a(n invisible) landmine?
}
