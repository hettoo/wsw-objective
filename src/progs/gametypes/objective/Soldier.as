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

const int RAGE_ARMOR = 45;
const int RAGE_TIME = 12;

const int SHIELD_ARMOR = 45;
const int SHIELD_TIME = 10;
const int SHIELD_RADIUS = 200;

const Sound RAGE_SOUND("items/quad_pickup");
const Sound SHIELD_SOUND("items/shell_pickup");

class Soldier : Class {
    Soldier() {
        spawnArmor = 20;
        maxArmor = 80;

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
        if (!player.takeArmor(RAGE_ARMOR)) {
            player.centerPrint(RAGE_ARMOR + " armor is required to rage");
        } else {
            player.giveItem(POWERUP_QUAD, RAGE_TIME);
            G_Sound(player.getEnt(), CHAN_ITEM, RAGE_SOUND.get(), ATTN_POWERUP);
        }
    }

    void classAction2(Player @player) {
        if (!player.takeArmor(SHIELD_ARMOR)) {
            player.centerPrint(SHIELD_ARMOR
                    + " armor is required to get a shield");
        } else {
            int team = player.getClient().team;
            for (int i = 0; i < players.getSize(); i++) {
                Player @other = players.get(i);
                if (@other != null) {
                    cClient @client = other.getClient();
                    if (@client != null && client.team == team
                            && G_Near(player, other, SHIELD_RADIUS))
                        other.giveItem(POWERUP_SHELL, SHIELD_TIME);
                    G_Sound(other.getEnt(), CHAN_ITEM, SHIELD_SOUND.get(),
                            ATTN_POWERUP);
                }
            }
        }
    }
}
