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

const int ARTILLERY_ARMOR = 70;
const int MAX_ARTILLERY_DISTANCE = 3000;

class Sniper : Class {
    Sniper() {
        spawnHealth = 80;
        spawnArmor = 20;

        maxHealth = 100;
        maxArmor = 100;
    }

    cString @getName() {
        return "Sniper";
    }

    void giveAmmoPack() {
        Class::giveAmmoPack();

        player.giveAmmo(WEAP_ELECTROBOLT, 6, 18, 5, 20);
        player.giveAmmo(WEAP_RIOTGUN, 0, 0, 10, 30);
    }

    void classAction1() {
        if (player.takeArmor(ARTILLERY_ARMOR)) {
            cEntity @ent = player.getEnt();

            cVec3 start = ent.getOrigin();
            start.z += ent.viewHeight;

            cVec3 end = start;
            cVec3 angles = ent.getAngles();
            cVec3 dir;
            angles.angleVectors(dir, null, null);
            end += dir * MAX_ARTILLERY_DISTANCE;

            cTrace trace;
            trace.doTrace(start, cVec3(-SMALL, -SMALL, -SMALL),
                    cVec3(SMALL, SMALL, SMALL), end, ent.entNum(), MASK_SOLID);

            player.getPlayers().getWorld().addArtillery(trace.getEndPos(), ent);
        } else {
            player.centerPrint("Not enough armor, " + ARTILLERY_ARMOR
                    + " required");
        }
    }
}
