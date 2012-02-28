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

enum ClassId {
    CLASS_SOLDIER,
    CLASS_ENGINEER,
    CLASS_MEDIC,
    CLASS_FIELD_OPS,
    CLASS_SNIPER,
    CLASSES
}

class Classes {
    Class@[] classes;

    Classes() {
        classes.resize(CLASSES);
        @classes[CLASS_SOLDIER] = Soldier();
        @classes[CLASS_ENGINEER] = Engineer();
        @classes[CLASS_MEDIC] = Medic();
        @classes[CLASS_FIELD_OPS] = FieldOps();
        @classes[CLASS_SNIPER] = Sniper();
    }

    Class @get(int id) {
        return classes[id];
    }

    int getIcon(int classId) {
        return classes[classId].getIcon();
    }

    int find(cString &newClass) {
        for (int i = 0; i < CLASSES; i++) {
            if (classes[i].getName() == newClass)
                return i;
        }
        return UNKNOWN;
    }

    cString @createMenu() {
        cString menu = "mecu \"Select Class\"";
        for (int i = 0; i < CLASSES; i++)
            menu += " \"" + classes[i].getName() + "\" "
                + " \"class " + classes[i].getName() + "\"";
        return menu;
    }
}
