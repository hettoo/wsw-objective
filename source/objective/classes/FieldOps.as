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
    }

    void giveSpawnAmmo(Player @player) {
        Class::giveSpawnAmmo(player);

        player.giveAmmo(WEAP_PLASMAGUN, 90);
        player.giveAmmo(WEAP_ROCKETLAUNCHER, 8);
    }

    bool giveAmmopack(Player @player) {
        bool given = Class::giveAmmopack(player);

        given = player.giveAmmo(WEAP_PLASMAGUN, 30, 120) || given;
        given = player.giveAmmo(WEAP_ROCKETLAUNCHER, 4, 12) || given;

        return given;
    }

    void spawn(Player @player) {
        Class::spawn(player);
        player.getClient().selectWeapon(WEAP_PLASMAGUN);
    }

    String @getName() {
        return "Field Ops";
    }

    void classAction1(Player @player) {
        cEntity @ent = player.getEnt();
        Vec3 origin = utils.throwOrigin(ent);
        Vec3 angles = utils.throwAngles(ent);
        if (!utils.canSpawn(origin, AMMOPACK_MINS, AMMOPACK_MAXS, ent.entNum))
            player.centerPrint("Can't spawn an ammopack there");
        else if (!player.takeArmor(AMMOPACK_ARMOR))
            player.centerPrint(AMMOPACK_ARMOR
                    + " armor is required to throw an ammopack");
        else
            itemSet.addAmmopack(origin, angles, player);
    }

    void classAction2(Player @player) {
        cEntity @ent = player.getEnt();
        Vec3 origin = utils.throwOrigin(ent);
        Vec3 angles = utils.throwAngles(ent);
        if (!utils.canSpawn(origin, CLUSTERBOMB_MINS, CLUSTERBOMB_MAXS,
                    ent.entNum))
            player.centerPrint("Can't spawn a clusterbomb there");
        else if (!player.takeArmor(CLUSTERBOMB_ARMOR))
            player.centerPrint(CLUSTERBOMB_ARMOR
                    + " armor is required to throw a clusterbomb");
        else
            clusterbombSet.add(origin, angles, player);
    }
}
