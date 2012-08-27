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

class Weapon {
    int weapon;
    int spawnAmmo;
    int ammo;
    int maxAmmo;

    Weapon(int weapon, int spawnAmmo, int ammo, int maxAmmo) {
        set(weapon, spawnAmmo, ammo, maxAmmo);
    }

    Weapon(int weapon, int spawnAmmo) {
        set(weapon, spawnAmmo, 0, 0);
    }

    void set(int weapon, int spawnAmmo, int ammo, int maxAmmo) {
        this.weapon = weapon;
        this.spawnAmmo = spawnAmmo;
        this.ammo = ammo;
        this.maxAmmo = maxAmmo;
    }

    int getWeapon() {
        return weapon;
    }

    int getSpawnAmmo() {
        return spawnAmmo;
    }

    int getAmmo() {
        return ammo;
    }

    int getMaxAmmo() {
        return maxAmmo;
    }
}
