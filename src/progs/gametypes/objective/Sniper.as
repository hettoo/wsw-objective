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

const int TRANSPORTER_ARMOR = 55;
const int TRANSPORTER_THROW_SPEED = 900;

class Sniper : Class {
    Transporter @transporter;

    Sniper() {
        spawnArmor = 0;
        maxArmor = 100;
    }

    cString @getName() {
        return "Sniper";
    }

    bool giveAmmopack() {
        bool gaveClass = Class::giveAmmopack();
        bool gaveEB = player.giveAmmo(WEAP_ELECTROBOLT, 6, 18, 5, 20);
        bool gaveRG = player.giveAmmo(WEAP_RIOTGUN, 0, 0, 10, 30);
        return gaveClass || gaveEB || gaveRG;
    }

    void classAction1() {
        cEntity @ent = player.getEnt();

        cVec3 start = ent.getOrigin();
        start.z += ent.viewHeight;

        cVec3 end = start;
        cVec3 angles = ent.getAngles();
        cVec3 dir;
        angles.angleVectors(dir, null, null);
        end += dir * MAX_ARTILLERY_DISTANCE;

        cTrace view;
        if (view.doTrace(start, cVec3(), cVec3(), end, ent.entNum(),
                    MASK_SOLID)) {
            cTrace up;
            if (up.doTrace(view.getEndPos(), cVec3(), cVec3(),
                        view.getEndPos() + cVec3(0, 0, ARTILLERY_HEIGHT), 0,
                        MASK_SOLID))
                player.centerPrint("Can't spawn artillery there");
            else if (!player.takeArmor(ARTILLERY_ARMOR)) {
                player.centerPrint(ARTILLERY_ARMOR
                        + " armor is required to spawn artillery");
            } else {
                player.getPlayers().getWorld().addArtillery(view.getEndPos(),
                        ent);
            }
        } else {
            player.centerPrint("Not solid or too far away to spawn artillery");
        }
    }

    void classAction2() {
        if (@transporter != null) {
            transporter.teleport();
            @transporter = null;
        } else {
            if (player.takeArmor(TRANSPORTER_ARMOR)) {
                cVec3 origin, angles, velocity;
                cEntity @ent = player.getEnt();
                G_InitThrow(player.getEnt(), TRANSPORTER_THROW_SPEED,
                        origin, angles, velocity);
                @transporter = player.getPlayers().getWorld().addTransporter(
                        origin, angles, velocity, ent);
                player.centerPrint("Press again to teleport yourself");
            } else {
                player.centerPrint(TRANSPORTER_ARMOR
                        + " armor is required to throw a transporter");
            }
        }
    }
}
