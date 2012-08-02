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
        primarySpawnAmmo = 50;
        primaryAmmo = 25;
        primaryMaxAmmo = 80;

        secondaryWeapon = WEAP_PLASMAGUN;
        secondarySpawnAmmo = 40;
        secondaryAmmo = 25;
        secondaryMaxAmmo = 70;
    }

    String @getName() {
        return "Medic";
    }

    void classAction1(Player @player) {
        cEntity @ent = player.getEnt();
        Vec3 origin = G_ThrowOrigin(ent);
        Vec3 angles = G_ThrowAngles(ent);
        if (!G_CanSpawn(origin, HEALTHPACK_MINS, HEALTHPACK_MAXS, ent.entNum))
            player.centerPrint("Can't spawn a healthpack there");
        else if (!player.takeArmor(HEALTH_ARMOR))
            player.centerPrint(HEALTH_ARMOR
                    + " armor is required to drop health");
        else
            itemSet.addHealthpack(origin, angles, player);
    }

    // classaction2: revive
}
