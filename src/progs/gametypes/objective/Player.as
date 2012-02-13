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

const float ARMOR_FRAME_BONUS = 0.002f;

class Player {
    Classes classes;

    cClient @client;
    cEntity @ent;

    Players @players;

    Player(Players @players) {
        @this.players = players;
        classes.register(this);
    }

    void init(cClient @newClient) {
        @client = newClient;
        @ent = client.getEnt();
    }

    bool isBot() {
        return client.isBot();
    }

    cClient @getClient() {
        return client;
    }

    cEntity @getEnt() {
        return ent;
    }

    Players @getPlayers() {
        return players;
    }

    int getClassIcon(int classId) {
        return classes.getIcon(classId);
    }

    int getClassIcon() {
        return classes.getIcon();
    }

    void showGameMenu() {
        client.execGameCommand(classes.createMenu());
    }

    void setHealth(int health) {
        ent.health = health;
    }

    void setArmor(int armor) {
        client.armor = armor;
    }

    cString @getClassName() {
        return classes.getName();
    }

    int getTeam() {
        return client.team;
    }

    void centerPrint(cString &msg) {
        G_CenterPrintMsg(ent, msg);
    }

    void setClass(int newClass) {
        if (classes.setNext(newClass))
            centerPrint("You will respawn as a " + classes.getNextName());
    }

    int getClassId() {
        return classes.getId();
    }

    void setClass(cString &newClass) {
        setClass(classes.find(newClass));
    }

    void setHUDStat(int stat, int value) {
        client.setHUDStat(stat, value);
    }

    bool takeArmor(float armor) {
        client.armor -= armor;
        if (client.armor < -0.5) {
            client.armor += armor;
            return false;
        }
        return true;
    }

    void giveItem(int item, int amount) {
        client.inventoryGiveItem(item);
        client.inventorySetCount(item, amount);
    }

    void giveAmmo(int weapon, int strongAmmo, int weakAmmo) {
        cItem @item = G_GetItem(weapon);

        if (client.canSelectWeapon(weapon)) {
            strongAmmo += client.inventoryCount(item.ammoTag);
            weakAmmo += client.inventoryCount(item.weakAmmoTag);
        } else {
            client.inventoryGiveItem(weapon);
        }

        client.inventorySetCount(item.ammoTag, strongAmmo);
        client.inventorySetCount(item.weakAmmoTag, weakAmmo);
    }

    bool giveAmmo(int weapon, int strongAmmo, int maxStrongAmmo, int weakAmmo,
            int maxWeakAmmo) {
        if (client.canSelectWeapon(weapon)) {
            cItem @item = G_GetItem(weapon);
            int currentWeakAmmo = client.inventoryCount(item.weakAmmoTag);
            int currentStrongAmmo = client.inventoryCount(item.ammoTag);

            if (currentWeakAmmo >= maxWeakAmmo
                    && currentStrongAmmo >= maxStrongAmmo)
                return false;

            if (currentWeakAmmo + weakAmmo > maxWeakAmmo)
                weakAmmo = maxWeakAmmo - currentWeakAmmo;
            if (currentStrongAmmo + strongAmmo > maxStrongAmmo)
                strongAmmo = maxStrongAmmo - currentStrongAmmo;
        }

        giveAmmo(weapon, strongAmmo, weakAmmo);
        return true;
    }

    bool giveAmmopack() {
        return classes.giveAmmopack();
    }

    void spawn() {
        classes.applyNext();
        classes.spawn();
        client.selectWeapon(-1);
        ent.respawnEffect();
    }

    void think() {
        if (client.team == TEAM_SPECTATOR)
            return;

        setHUDStat(STAT_PROGRESS_SELF, 0);
        setHUDStat(STAT_PROGRESS_OTHER, 0);
        setHUDStat(STAT_IMAGE_OTHER, 0);
        classes.think();
        GENERIC_ChargeGunblade(client);
    }

    void classAction1() {
        classes.classAction1();
    }

    void classAction2() {
        classes.classAction2();
    }
}
