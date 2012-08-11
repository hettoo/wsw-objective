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

const float ATTN_ITEM_SPAWN = 4.0;
const float ATTN_ITEM_PICKUP = 4.5;
const float ATTN_POWERUP = 3.5;

const int PROGRESS_FINISHED = 100;

String WTF = "???";
const int UNKNOWN = -1;

Utils utils;

class Utils {
    bool isNewline(String byte) {
        return byte == "\n" || byte == "\r";
    }

    bool isWhitespace(String byte) {
        return byte == " " || byte == "\t" || isNewline(byte);
    }

    String @replaceSpaces(String &string, String replacement) {
        String result;
        for (uint i = 0; i < string.len(); i++) {
            String character = string.substr(i, 1);
            if (character == " ")
                result += replacement;
            else
                result += character;
        }
        return result;
    }

    String @replaceSpaces(String &string) {
        return replaceSpaces(string, "_");
    }

    Vec3 throwAngles(cEntity @ent) {
        Vec3 angles = ent.angles + Vec3(-10, 0, 0);
        if (angles.x < -90)
            angles.x = -90;
        return angles;
    }

    Vec3 throwOrigin(cEntity @ent) {
        Vec3 origin = ent.origin;
        origin.z += ent.viewHeight;

        Vec3 angles = throwAngles(ent);
        Vec3 dir, dir2, dir3;
        angles.angleVectors(dir, dir2, dir3);
        origin += dir * 24;
        return origin;
    }

    bool canSpawn(Vec3 origin, Vec3 mins, Vec3 maxs, int ignore) {
        return !cTrace().doTrace(origin, mins , maxs, origin, ignore,
                MASK_PLAYERSOLID);
    }

    bool canSpawn(Vec3 origin, Vec3 mins, Vec3 maxs) {
        return canSpawn(origin, mins, maxs, -1);
    }

    String @getTeamName(int team) {
        return G_GetTeam(team).name;
    }

    bool near(Vec3 a, Vec3 b, float radius) {
        return a.distance(b) <= radius;
    }

    bool near(cEntity @a, cEntity @b, float radius) {
        return @a != null && @b != null && !a.isGhosting() && !b.isGhosting()
            && near(a.origin, b.origin, radius);
    }

    bool near(Player @a, Player @b, float radius) {
        return @a != null && @b != null && near(a.getEnt(), b.getEnt(), radius);
    }

    cEntity @spawnIcon(int image, int team, Vec3 origin) {
        cEntity @minimap = @G_SpawnEntity("minimap_icon");
        minimap.type = ET_MINIMAP_ICON;
        minimap.modelindex = image;
        minimap.team = team;
        minimap.origin = origin;
        minimap.solid = SOLID_NOT;
        minimap.frame = 24;
        minimap.svflags |= SVF_BROADCAST;
        minimap.svflags &= ~SVF_NOCLIENT;
        return minimap;
    }

    String @join(String@[] list, String glue) {
        String result = "";
        for (uint i = 0; i < list.size(); i++) {
            if (i > 0)
                result += glue;
            result += list[i];
        }
        return result;
    }

    String @join(String@[] list) {
        return join(list, " ");
    }

    void debug(String message) {
        G_Print(message + "\n");
    }
}
