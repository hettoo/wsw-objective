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
    }

    void giveSpawnAmmo(Player @player) {
        Class::giveSpawnAmmo(player);

        player.giveAmmo(WEAP_RIOTGUN, 10);
        player.giveAmmo(WEAP_LASERGUN, 80);
    }

    bool giveAmmopack(Player @player) {
        bool given = Class::giveAmmopack(player);

        given = player.giveAmmo(WEAP_RIOTGUN, 4, 14) || given;
        given = player.giveAmmo(WEAP_LASERGUN, 30, 100) || given;

        return given;
    }

    void spawn(Player @player) {
        Class::spawn(player);
        player.getClient().selectWeapon(WEAP_RIOTGUN);
    }

    String @getName() {
        return "Engineer";
    }

    void classAction1(Player @player) {
        cEntity @ent = player.getEnt();
        Vec3 origin = utils.throwOrigin(ent);
        Vec3 angles = utils.throwAngles(ent);
        if (!utils.canSpawn(origin, BOMB_MINS, BOMB_MAXS, ent.entNum)) {
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
