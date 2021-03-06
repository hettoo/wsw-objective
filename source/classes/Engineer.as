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
const int MINE_ARMOR = 40;

class Engineer : Class {
    Engineer() {
        spawnArmor = 40;
        maxArmor = 90;

        weaponSet.insertLast(Weapon(WEAP_LASERGUN, 80, 30, 100));
        weaponSet.insertLast(Weapon(WEAP_RIOTGUN, 10, 4, 14));
    }

    String @getName() {
        return "Engineer";
    }

    void classAction1(Player @player) {
        cEntity @ent = player.getEnt();
        Vec3 origin = utils.throwOrigin(ent);
        Vec3 angles = utils.throwAngles(ent);
        if (!utils.canSpawn(origin, BOMB_MINS, BOMB_MAXS, ent.entNum))
            player.centerPrint("Can't spawn a bomb there");
        else if (!player.takeArmor(BOMB_ARMOR))
            player.centerPrint(BOMB_ARMOR
                    + " armor is required to throw a bomb");
        else
            bombSet.add(origin, angles, player);
    }

    void classAction2(Player @player) {
        cEntity @ent = player.getEnt();
        Vec3 origin = utils.throwOrigin(ent);
        Vec3 angles = utils.throwAngles(ent);
        if (!utils.canSpawn(origin, MINE_MINS, MINE_MAXS, ent.entNum))
            player.centerPrint("Can't spawn a mine there");
        else if (!mineSet.canAdd(player))
            player.centerPrint("Your team has too much mines");
        else if (!player.takeArmor(MINE_ARMOR))
            player.centerPrint(MINE_ARMOR
                    + " armor is required to spawn a mine");
        else
            mineSet.add(origin, angles, player);
    }
}
