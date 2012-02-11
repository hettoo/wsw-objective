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
        spawnHealth = 100;
        spawnArmor = 40;

        maxHealth = 100;
        maxArmor = 100;
    }

    cString @getName() {
        return "Engineer";
    }

    cString @getSimpleName() {
        return "engineer";
    }

    void giveAmmoPack() {
        Class::giveAmmoPack();

        player.giveAmmo(WEAP_RIOTGUN, 5, 20, 5, 5);
        player.giveAmmo(WEAP_LASERGUN, 10, 40, 60, 80);
    }

    void classAction1() {
        if (player.takeArmor(BOMB_ARMOR)) {
            cEntity @ent = player.getEnt();

            cVec3 origin = ent.getOrigin();
            origin.z += ent.viewHeight;

            cVec3 @angles = ent.getAngles() + cVec3(-10, 0, 0);
            if (angles.x < -90)
                angles.x = -90;

            cVec3 dir;
            angles.angleVectors(dir, null, null);
            origin += dir * 24;

            cVec3 velocity = ent.getVelocity() + dir * BOMB_THROW_SPEED;

            player.getPlayers().getWorld().addBomb(origin, ent.getAngles(),
                    velocity, ent);
        } else {
            player.centerPrint(BOMB_ARMOR
                    + " armor is required to plant a bomb");
        }
    }
}
