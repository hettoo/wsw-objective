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

const int RAGE_ARMOR = 80;
const int RAGE_TIME = 15;

const int SHIELD_ARMOR = 65;
const int SHIELD_TIME = 18;

class Soldier : Class {
    float raging;

    Soldier() {
        spawnHealth = 100;
        spawnArmor = 30;

        maxHealth = 100;
        maxArmor = 80;

        raging = 0;
    }

    cString @getName() {
        return "Soldier";
    }

    cString @getSimpleName() {
        return "soldier";
    }

    void giveAmmoPack() {
        Class::giveAmmoPack();

        player.giveAmmo(WEAP_ROCKETLAUNCHER, 8, 20, 10, 30);
        player.giveAmmo(WEAP_RIOTGUN, 5, 20, 10, 30);
    }

    void classAction1() {
        if (raging > 0)
            player.centerPrint("You are already raging");
        else if (!player.takeArmor(RAGE_ARMOR))
            player.centerPrint(RAGE_ARMOR + " armor is required to rage");
        else
            player.giveItem(POWERUP_QUAD, RAGE_TIME);
    }

    void classAction2() {
        if (raging > 0)
            player.centerPrint("You already have a shield");
        else if (!player.takeArmor(SHIELD_ARMOR))
            player.centerPrint(SHIELD_ARMOR
                    + " armor is required to get a shield");
        else
            player.giveItem(POWERUP_SHELL, SHIELD_TIME);
    }
}
