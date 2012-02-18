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
const float HEALTHPACK_HEALTH = 20;

class Class {
    int spawnHealth;
    int spawnArmor;

    int maxHealth;
    int maxArmor;

    int classIcon;

    int primaryWeapon;
    int primaryWeakSpawnAmmo;
    int primaryWeakAmmo;
    int primaryWeakMaxAmmo;
    int primaryStrongSpawnAmmo;
    int primaryStrongAmmo;
    int primaryStrongMaxAmmo;

    int secondaryWeapon;
    int secondaryWeakSpawnAmmo;
    int secondaryWeakAmmo;
    int secondaryWeakMaxAmmo;
    int secondaryStrongSpawnAmmo;
    int secondaryStrongAmmo;
    int secondaryStrongMaxAmmo;

    Class() {
        spawnHealth = 80;
        maxHealth = 100;

        classIcon = G_ImageIndex("gfx/hud/icons/objective/classes/"
                + getSimpleName());
    }

    cString @getSimpleName() {
        return G_ReplaceSpaces(getName().tolower());
    }

    cString @getName() {
        return WTF;
    }

    int getIcon() {
        return classIcon;
    }

    bool giveAmmopack(Player @player) {
        bool gaveGL = player.giveAmmo(WEAP_GRENADELAUNCHER, 0, 0, 4, 12);
        bool gaveMG = player.giveAmmo(WEAP_MACHINEGUN, 40, 100, 0, 0);

        bool gavePrimary = player.giveAmmo(primaryWeapon,
                primaryStrongAmmo, primaryStrongMaxAmmo,
                primaryWeakAmmo, primaryWeakMaxAmmo);
        bool gaveSecondary = player.giveAmmo(secondaryWeapon,
                secondaryStrongAmmo, secondaryStrongMaxAmmo,
                secondaryWeakAmmo, secondaryWeakMaxAmmo);

        return gaveGL || gaveMG || gavePrimary || gaveSecondary;
    }

    bool giveHealthpack(Player @player) {
        cEntity @ent = player.getEnt();
        if (ent.health == maxHealth)
            return false;
        ent.health += HEALTHPACK_HEALTH;
        if (ent.health > maxHealth)
            ent.health = maxHealth;
        return true;
    }

    void giveSpawnAmmo(Player @player) {
        player.giveAmmo(WEAP_GUNBLADE, 4, 0);
        player.giveAmmo(WEAP_GRENADELAUNCHER, 0, 6);
        player.giveAmmo(WEAP_MACHINEGUN, 60, 0);

        player.giveAmmo(primaryWeapon,
                primaryStrongSpawnAmmo, primaryWeakSpawnAmmo);
        player.giveAmmo(secondaryWeapon,
                secondaryStrongSpawnAmmo, secondaryWeakSpawnAmmo);
    }

    void spawn(Player @player) {
        if (player.isBot() && random() < BOT_CLASS_CHANGE_CHANCE)
            player.setClass(brandom(0, CLASSES - 1));

        giveSpawnAmmo(player);
        player.getClient().selectWeapon(primaryWeapon);

        player.setHealth(spawnHealth);
        player.setArmor(spawnArmor);
        player.setHUDStat(player.getTeam() == TEAM_ALPHA
                ? STAT_IMAGE_ALPHA : STAT_IMAGE_BETA, classIcon);
    }

    void classAction1(Player @player) {
        player.centerPrint("This class has no classaction1");
    }

    void classAction2(Player @player) {
        player.centerPrint("This class has no classaction2");
    }

    void addArmor(Player @player, float armor) {
        cClient @client = player.getClient();
        client.armor += armor;
        if (client.armor > maxArmor)
            client.armor = maxArmor;
    }
}
