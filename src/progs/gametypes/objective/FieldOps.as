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
const int CLUSTERBOMB_ARMOR = 50;

class FieldOps : Class {
    FieldOps() {
        spawnArmor = 20;
        maxArmor = 90;

        primaryWeapon = WEAP_PLASMAGUN;
        primaryStrongSpawnAmmo = 50;
        primaryStrongAmmo = 25;
        primaryStrongMaxAmmo = 80;
        primaryWeakSpawnAmmo = 60;
        primaryWeakAmmo = 30;
        primaryWeakMaxAmmo = 100;

        secondaryWeapon = WEAP_ROCKETLAUNCHER;
        secondaryStrongSpawnAmmo = 10;
        secondaryStrongAmmo = 4;
        secondaryStrongMaxAmmo = 20;
        secondaryWeakSpawnAmmo = 15;
        secondaryWeakAmmo = 5;
        secondaryWeakMaxAmmo = 25;
    }

    String @getName() {
        return "Field Ops";
    }

    void classAction1(Player @player) {
        cEntity @ent = player.getEnt();
        Vec3 origin = G_ThrowOrigin(ent);
        Vec3 angles = G_ThrowAngles(ent);
        if (!G_CanSpawn(origin, AMMOPACK_MINS, AMMOPACK_MAXS, ent.entNum))
            player.centerPrint("Can't spawn an ammopack there");
        else if (!player.takeArmor(AMMOPACK_ARMOR))
            player.centerPrint(AMMOPACK_ARMOR
                    + " armor is required to throw an ammopack");
        else
            itemSet.addAmmopack(origin, angles, player);
    }

    void classAction2(Player @player) {
        cEntity @ent = player.getEnt();
        Vec3 origin = G_ThrowOrigin(ent);
        Vec3 angles = G_ThrowAngles(ent);
        if (!G_CanSpawn(origin, CLUSTERBOMB_MINS, CLUSTERBOMB_MAXS,
                    ent.entNum))
            player.centerPrint("Can't spawn a clusterbomb there");
        else if (!player.takeArmor(CLUSTERBOMB_ARMOR))
            player.centerPrint(CLUSTERBOMB_ARMOR
                    + " armor is required to throw a clusterbomb");
        else
            clusterbombSet.add(origin, angles, player);
    }
}
