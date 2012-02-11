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

enum ClassIds {
    CLASS_SOLDIER,
    CLASS_ENGINEER,
    CLASS_MEDIC,
    CLASS_SNIPER,
    CLASSES
}

class Classes {
    Class@[] classes;
    int currentClass;
    int nextClass;

    Classes() {
        classes.resize(CLASSES);
        @classes[CLASS_SOLDIER] = Soldier();
        @classes[CLASS_ENGINEER] = Engineer();
        @classes[CLASS_MEDIC] = Medic();
        @classes[CLASS_SNIPER] = Sniper();

        currentClass = CLASS_SOLDIER;
        nextClass = CLASSES;
    }

    void register(Player @player) {
        for (int i = 0; i < CLASSES; i++)
            classes[i].register(player);
    }

    int getId() {
        return currentClass;
    }

    Class @getClass() {
        return classes[currentClass];
    }

    int getIcon() {
        return classes[currentClass].getIcon();
    }

    bool setNext(int newClass) {
        if (newClass >= 0 && newClass < CLASSES) {
            nextClass = newClass;
            return true;
        }
        return false;
    }

    int find(cString &newClass) {
        for (int i = 0; i < CLASSES; i++) {
            if (classes[i].getName() == newClass)
                return i;
        }
        return UNKNOWN;
    }

    cString @getName() {
        return classes[currentClass].getName();
    }

    cString @getNextName() {
        return classes[nextClass].getName();
    }

    cString @createMenu() {
        cString menu = "mecu \"Select Class\"";
        for (int i = 0; i < CLASSES; i++)
            menu += classes[i].getName() + " \"class " + classes[i].getName() + "\"";
        return menu;
    }

    void applyNext() {
        if (nextClass < CLASSES) {
            currentClass = nextClass;
            nextClass = CLASSES;
        }
    }

    void spawn() {
        classes[currentClass].spawn();
    }

    void addArmor(float armor) {
        classes[currentClass].addArmor(armor);
    }

    void classAction1() {
        classes[currentClass].classAction1();
    }

    void think() {
        addArmor(ARMOR_FRAME_BONUS * frameTime);
        getClass().think();
    }
}
