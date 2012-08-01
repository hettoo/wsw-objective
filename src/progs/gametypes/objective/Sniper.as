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

const int ARTILLERY_ARMOR = 65;
const int MAX_ARTILLERY_DISTANCE = 3000;

const int TRANSPORTER_ARMOR = 35;

class Sniper : Class {
    Transporter @transporter;

    Sniper() {
        spawnArmor = 0;
        maxArmor = 100;

        primaryWeapon = WEAP_ELECTROBOLT;
        primaryStrongSpawnAmmo = 8;
        primaryStrongAmmo = 15;
        primaryStrongMaxAmmo = 4;
        primaryWeakSpawnAmmo = 10;
        primaryWeakAmmo = 5;
        primaryWeakMaxAmmo = 20;

        secondaryWeapon = WEAP_RIOTGUN;
        secondaryStrongSpawnAmmo = 2;
        secondaryStrongAmmo = 3;
        secondaryStrongMaxAmmo = 8;
        secondaryWeakSpawnAmmo = 10;
        secondaryWeakAmmo = 5;
        secondaryWeakMaxAmmo = 20;
    }

    String @getName() {
        return "Sniper";
    }

    void classAction1(Player @player) {
        cEntity @ent = player.getEnt();

        Vec3 start = ent.origin;
        start.z += ent.viewHeight;

        Vec3 end = start;
        Vec3 angles = ent.angles;
        Vec3 dir, dir2, dir3;
        angles.angleVectors(dir, dir2, dir3);
        end += dir * MAX_ARTILLERY_DISTANCE;

        cTrace view;
        if (view.doTrace(start, Vec3(), Vec3(), end, ent.entNum,
                    MASK_SOLID)) {
            cTrace up;
            if (up.doTrace(view.get_endPos(), Vec3(), Vec3(),
                        view.get_endPos() + Vec3(0, 0, ARTILLERY_HEIGHT), 0,
                        MASK_SOLID))
                player.centerPrint("Can't spawn artillery there");
            else if (!player.takeArmor(ARTILLERY_ARMOR)) {
                player.centerPrint(ARTILLERY_ARMOR
                        + " armor is required to spawn artillery");
            } else {
                artillerySet.add(view.get_endPos(), player);
            }
        } else {
            player.centerPrint("Not solid or too far away to spawn artillery");
        }
    }

    void classAction2(Player @player) {
        if (@transporter != null && transporter.isActive()) {
            transporter.teleport();
            @transporter = null;
        } else {
            cEntity @ent = player.getEnt();
            Vec3 origin = G_ThrowOrigin(ent);
            Vec3 angles = G_ThrowAngles(ent);
            if (!G_CanSpawn(origin, TRANSPORTER_MINS, TRANSPORTER_MAXS,
                        ent.entNum)) {
                player.centerPrint("Can't spawn a transporter there");
            } else if (!player.takeArmor(TRANSPORTER_ARMOR)) {
                player.centerPrint(TRANSPORTER_ARMOR
                        + " armor is required to throw a transporter");
            } else {
                @transporter = transporterSet.add(origin, angles, player);
                player.centerPrint("Press again to teleport yourself");
            }
        }
    }
}
