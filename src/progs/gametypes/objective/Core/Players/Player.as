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

    void setClass(int newClass) {
        nextClass = newClass;
    }

    void setClass(cString &newClass) {
        if (newClass == soldier.getName())
            nextClass = CLASS_SOLDIER;
        else if (newClass == medic.getName())
            nextClass = CLASS_MEDIC;
        else if (newClass == engineer.getName())
            nextClass = CLASS_ENGINEER;
        else if (newClass == sniper.getName())
            nextClass = CLASS_SNIPER;
    }

    void giveWeapon(int weapon, int strongAmmo, int weakAmmo) {
        cItem @item = G_GetItem(weapon);

        client.inventoryGiveItem(weapon);
        client.inventorySetCount(item.ammoTag, strongAmmo);
        client.inventorySetCount(item.weakAmmoTag, weakAmmo);
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
    }
}
