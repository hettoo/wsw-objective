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
const float HEALTHPACK_HEALTH = 15;

class Class {
    int spawnHealth;
    int spawnArmor;

    int maxHealth;
    int maxArmor;

    Image @classIcon;

    int primaryWeapon;
    int primarySpawnAmmo;
    int primaryAmmo;
    int primaryMaxAmmo;

    int secondaryWeapon;
    int secondarySpawnAmmo;
    int secondaryAmmo;
    int secondaryMaxAmmo;

    Class() {
        spawnHealth = 70;
        maxHealth = 90;

        @classIcon = Image("hud/icons/objective/classes/" + getSimpleName());
    }

    String @getSimpleName() {
        return utils.replaceSpaces(getName().tolower());
    }

    String @getName() {
        return WTF;
    }

    int getIcon() {
        return classIcon.get();
    }

    bool giveAmmopack(Player @player) {
        bool gaveGL = player.giveAmmo(WEAP_GRENADELAUNCHER, 2, 5);
        bool gaveMG = player.giveAmmo(WEAP_MACHINEGUN, 40, 100);

        bool gavePrimary = player.giveAmmo(primaryWeapon, primaryAmmo,
                primaryMaxAmmo);
        bool gaveSecondary = player.giveAmmo(secondaryWeapon, secondaryAmmo,
                secondaryMaxAmmo);

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
        player.giveAmmo(WEAP_GUNBLADE, 4);
        player.giveAmmo(WEAP_GRENADELAUNCHER, 2);
        player.giveAmmo(WEAP_MACHINEGUN, 60);

        player.giveAmmo(primaryWeapon, primarySpawnAmmo);
        player.giveAmmo(secondaryWeapon, secondarySpawnAmmo);
    }

    void spawn(Player @player) {
        if (player.isBot() && random() < BOT_CLASS_CHANGE_CHANCE)
            player.setClass(brandom(0, CLASSES - 1));

        giveSpawnAmmo(player);
        player.getClient().selectWeapon(primaryWeapon);

        player.setHealth(spawnHealth);
        player.setArmor(spawnArmor);
        player.setHUDStat(player.getTeam() == TEAM_ALPHA
                ? STAT_IMAGE_ALPHA : STAT_IMAGE_BETA, classIcon.get());
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
