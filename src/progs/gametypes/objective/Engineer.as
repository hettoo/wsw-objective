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

const int BOMB_THROW_SPEED = 400;
const int BOMB_ARMOR = 70;

class Engineer : Class {
    Engineer() {
        spawnArmor = 40;
        maxArmor = 100;
    }

    cString @getName() {
        return "Engineer";
    }

    bool giveAmmopack() {
        bool gaveClass = Class::giveAmmopack();
        bool gaveRG = player.giveAmmo(WEAP_RIOTGUN, 5, 20, 5, 5);
        bool gaveLG = player.giveAmmo(WEAP_LASERGUN, 10, 40, 60, 80);
        return gaveClass || gaveRG || gaveLG;
    }

    void classAction1() {
        if (player.takeArmor(BOMB_ARMOR)) {
            cVec3 origin, angles, velocity;
            cEntity @ent = player.getEnt();
            G_InitThrow(player.getEnt(), BOMB_THROW_SPEED,
                    origin, angles, velocity);
            player.getPlayers().getWorld().addBomb(origin, angles, velocity,
                    ent);
        } else {
            player.centerPrint(BOMB_ARMOR
                    + " armor is required to throw a bomb");
        }
    }

    // classaction2: shoot a grenade far away?
    // create a turret (perhaps it might only be activated if a teammember is
    // standing next to it)?
    // spawn a(n invisible) landmine?
    // create a fence, destroyable by satchel charges and / or bombs?
}
