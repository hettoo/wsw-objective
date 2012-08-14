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
    }

    void giveSpawnAmmo(Player @player) {
        Class::giveSpawnAmmo(player);

        player.giveAmmo(WEAP_LASERGUN, 110);
        player.giveAmmo(WEAP_PLASMAGUN, 60);
    }

    bool giveAmmopack(Player @player) {
        bool given = Class::giveAmmopack(player);

        given = player.giveAmmo(WEAP_LASERGUN, 40, 150) || given;
        given = player.giveAmmo(WEAP_PLASMAGUN, 30, 90) || given;

        return given;
    }

    void spawn(Player @player) {
        Class::spawn(player);
        player.getClient().selectWeapon(WEAP_LASERGUN);
    }

    String @getName() {
        return "Medic";
    }

    void classAction1(Player @player) {
        cEntity @ent = player.getEnt();
        Vec3 origin = utils.throwOrigin(ent);
        Vec3 angles = utils.throwAngles(ent);
        if (!utils.canSpawn(origin, HEALTHPACK_MINS, HEALTHPACK_MAXS,
                    ent.entNum))
            player.centerPrint("Can't spawn a healthpack there");
        else if (!player.takeArmor(HEALTH_ARMOR))
            player.centerPrint(HEALTH_ARMOR
                    + " armor is required to drop health");
        else
            itemSet.addHealthpack(origin, angles, player);
    }

    // classaction2: revive
}
