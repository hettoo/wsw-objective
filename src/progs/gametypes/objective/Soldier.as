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

const int RAGE_ARMOR = 70;
const int RAGE_TIME = 18;

const int SHIELD_ARMOR = 60;
const int SHIELD_TIME = 20;

class Soldier : Class {
    Soldier() {
        spawnArmor = 30;
        maxArmor = 90;

        primaryWeapon = WEAP_ROCKETLAUNCHER;
        primaryStrongSpawnAmmo = 12;
        primaryStrongAmmo = 4;
        primaryStrongMaxAmmo = 20;
        primaryWeakSpawnAmmo = 15;
        primaryWeakAmmo = 8;
        primaryWeakMaxAmmo = 30;

        secondaryWeapon = WEAP_RIOTGUN;
        secondaryStrongSpawnAmmo = 10;
        secondaryStrongAmmo = 5;
        secondaryStrongMaxAmmo = 15;
        secondaryWeakSpawnAmmo = 12;
        secondaryWeakAmmo = 5;
        secondaryWeakMaxAmmo = 15;
    }

    cString @getName() {
        return "Soldier";
    }

    void classAction1(Player @player) {
        if (!player.takeArmor(RAGE_ARMOR))
            player.centerPrint(RAGE_ARMOR + " armor is required to rage");
        else
            player.giveItem(POWERUP_QUAD, RAGE_TIME);
    }

    // TODO: shield the teammembers around him as well?
    void classAction2(Player @player) {
        if (!player.takeArmor(SHIELD_ARMOR))
            player.centerPrint(SHIELD_ARMOR
                    + " armor is required to get a shield");
        else
            player.giveItem(POWERUP_SHELL, SHIELD_TIME);
    }
}
