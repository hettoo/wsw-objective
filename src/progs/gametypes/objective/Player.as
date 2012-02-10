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

const float ARMOR_FRAME_BONUS = 0.0015f;

class Player {
    int currentClass;
    int nextClass;

    cClient @client;
    cEntity @ent;

    Soldier soldier;
    Medic medic;
    Engineer engineer;
    Sniper sniper;

    Player() {
        currentClass = CLASS_SOLDIER;
        nextClass = CLASSES;
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

    void showGameMenu() {
        cString menu = "mecu \"Select Class\"";
        cString name;
        name = soldier.getName();
        menu += name + " \"class " + name + "\"";
        name = medic.getName();
        menu += name + " \"class " + name + "\"";
        name = engineer.getName();
        menu += name + " \"class " + name + "\"";
        name = sniper.getName();
        menu += name + " \"class " + name + "\"";
        client.execGameCommand(menu);
    }

    void setHealth(int health) {
        ent.health = health;
    }

    void setArmor(int armor) {
        client.armor = armor;
    }

    /*
     * Note: doesn't belong here...
     */
    cString @getClassName(int classId) {
        switch (classId) {
            case CLASS_SOLDIER:
                return soldier.getName();
            case CLASS_MEDIC:
                return medic.getName();
            case CLASS_ENGINEER:
                return engineer.getName();
            case CLASS_SNIPER:
                return sniper.getName();
        }
        return WTF + "";
    }

    cString @getClassName() {
        return getClassName(currentClass);
    }

    void centerPrint(cString &msg) {
        G_CenterPrintMsg(ent, msg);
    }

    void setClass(int newClass) {
        nextClass = newClass;
        centerPrint("You will respawn as a " + getClassName(nextClass));
    }

    int getClass() {
        return currentClass;
    }

    void setClass(cString &newClass) {
        if (newClass == soldier.getName())
            setClass(CLASS_SOLDIER);
        else if (newClass == medic.getName())
            setClass(CLASS_MEDIC);
        else if (newClass == engineer.getName())
            setClass(CLASS_ENGINEER);
        else if (newClass == sniper.getName())
            setClass(CLASS_SNIPER);
    }

    bool takeArmor(float armor) {
        client.armor -= armor;
        if (client.armor < 0) {
            client.armor += armor;
            return false;
        }
        return true;
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

    void giveAmmo(int weapon, int strongAmmo, int maxStrongAmmo, int weakAmmo,
            int maxWeakAmmo) {
        if (client.canSelectWeapon(weapon)) {
            cItem @item = G_GetItem(weapon);
            if (client.inventoryCount(item.ammoTag) + strongAmmo
                    > maxStrongAmmo)
                strongAmmo = maxStrongAmmo
                    - client.inventoryCount(item.ammoTag);
            if (client.inventoryCount(item.weakAmmoTag) + weakAmmo
                    > maxWeakAmmo)
                weakAmmo = maxWeakAmmo
                    - client.inventoryCount(item.weakAmmoTag);
        }

        giveAmmo(weapon, strongAmmo, weakAmmo);
    }

    void applyNextClass() {
        if (nextClass < CLASSES) {
            currentClass = nextClass;
            nextClass = CLASSES;
        }
    }

    void spawn() {
        applyNextClass();
        switch (currentClass) {
            case CLASS_SOLDIER:
                soldier.spawn(this);
                break;
            case CLASS_MEDIC:
                medic.spawn(this);
                break;
            case CLASS_ENGINEER:
                engineer.spawn(this);
                break;
            case CLASS_SNIPER:
                sniper.spawn(this);
                break;
        }
        client.selectWeapon(-1);
        ent.respawnEffect();
    }

    void think() {
        if (client.team == TEAM_SPECTATOR)
            return;

        float armor = frameTime * ARMOR_FRAME_BONUS;
        switch (currentClass) {
            case CLASS_SOLDIER:
                soldier.addArmor(this, armor);
                break;
            case CLASS_MEDIC:
                medic.addArmor(this, armor);
                break;
            case CLASS_ENGINEER:
                engineer.addArmor(this, armor);
                break;
            case CLASS_SNIPER:
                sniper.addArmor(this, armor);
                break;
        }

        client.setHUDStat(STAT_PROGRESS_SELF, 0);
    }
}
