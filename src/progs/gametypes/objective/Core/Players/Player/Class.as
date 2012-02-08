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

const float BOT_CLASS_CHANGE_CHANCE = 0.2f;

enum Classes {
    CLASS_SOLDIER,
    CLASS_ENGINEER,
    CLASS_MEDIC,
    CLASS_SNIPER,
    CLASSES
}

class Class {
    int spawnHealth;
    int spawnArmor;

    int maxHealth;
    int maxArmor;

    int spawnAmmoPacks;

    Class() {
        spawnAmmoPacks = 2;
    }

    void giveAmmoPack(Player @player) {
        player.giveWeapon(WEAP_GRENADELAUNCHER, 0, 0, 5, 10);
        player.giveWeapon(WEAP_MACHINEGUN, 0, 0, 40, 120);
    }

    void giveSpawnAmmoPacks(Player @player) {
        for (int i = 0; i < spawnAmmoPacks; i++)
            giveAmmoPack(player);
    }

    void spawn(Player @player) {
        if (gametype.isInstagib()) {
            player.giveWeapon(WEAP_INSTAGUN, 1, 1);
        } else {
            if (player.isBot() && random() < BOT_CLASS_CHANGE_CHANCE)
                player.setClass(brandom(0, CLASSES - 1));

            player.giveWeapon(WEAP_GUNBLADE, 0, 0);
            giveSpawnAmmoPacks(player);
        }
    }
}
