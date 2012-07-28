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

const int HEALTH_ARMOR = 10;

class Medic : Class {
    Medic() {
        spawnHealth = 90;
        maxHealth = 110;

        spawnArmor = 30;
        maxArmor = 80;

        primaryWeapon = WEAP_LASERGUN;
        primaryStrongSpawnAmmo = 50;
        primaryStrongAmmo = 25;
        primaryStrongMaxAmmo = 80;
        primaryWeakSpawnAmmo = 60;
        primaryWeakAmmo = 30;
        primaryWeakMaxAmmo = 100;

        secondaryWeapon = WEAP_PLASMAGUN;
        secondaryStrongSpawnAmmo = 40;
        secondaryStrongAmmo = 25;
        secondaryStrongMaxAmmo = 70;
        secondaryWeakSpawnAmmo = 50;
        secondaryWeakAmmo = 30;
        secondaryWeakMaxAmmo = 90;
    }

    String @getName() {
        return "Medic";
    }

    void classAction1(Player @player) {
        Vec3 origin, angles;
        cEntity @ent = player.getEnt();
        if (!G_CheckInitThrow(player.getEnt(), origin, angles,
                    HEALTHPACK_MINS, HEALTHPACK_MAXS))
            player.centerPrint("Can't spawn a healthpack there");
        else if (!player.takeArmor(HEALTH_ARMOR))
            player.centerPrint(HEALTH_ARMOR
                    + " armor is required to drop health");
        else
            itemSet.addHealthpack(origin, angles, player);
    }

    // classaction2: revive
}
