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

String @G_ReplaceSpaces(String &string, String replacement) {
    String result;
    for (int i = 0; i < string.len(); i++) {
        String character = string.substr(i, 1);
        if (character == " ")
            result += replacement;
        else
            result += character;
    }
    return result;
}

String @G_ReplaceSpaces(String &string) {
    return G_ReplaceSpaces(string, "_");
}

void G_InitThrow(cEntity @ent, Vec3 @origin, Vec3 @angles) {
    origin = ent.origin;
    origin.z += ent.viewHeight;

    angles = ent.angles + Vec3(-10, 0, 0);
    if (angles.x < -90)
        angles.x = -90;

    Vec3 dir;
    angles.angleVectors(dir, null, null);
    origin += dir * 24;
}

bool G_CheckInitThrow(cEntity @ent, Vec3 @origin, Vec3 @angles,
        Vec3 @mins, Vec3 @maxs) {
    G_InitThrow(ent, origin, angles);
    return G_CanSpawn(origin, mins, maxs, ent.entNum);
}

bool G_CanSpawn(Vec3 @origin, Vec3 @mins, Vec3 @maxs, int ignore) {
    return !cTrace().doTrace(origin, mins , maxs, origin, ignore,
            MASK_PLAYERSOLID);
}

bool G_CanSpawn(Vec3 @origin, Vec3 @mins, Vec3 @maxs) {
    return G_CanSpawn(origin, mins, maxs, -1);
}

String @G_GetTeamName(int team) {
    return G_GetTeam(team).getName();
}

bool G_Near(Vec3 @a, Vec3 @b, float radius) {
    return @a != null && @b != null && a.distance(b) <= radius;
}

bool G_Near(cEntity @a, cEntity @b, float radius) {
    return @a != null && @b != null && !a.isGhosting() && !b.isGhosting()
        && G_Near(a.origin, b.origin, radius);
}

bool G_Near(Player @a, Player @b, float radius) {
    return @a != null && @b != null && G_Near(a.getEnt(), b.getEnt(), radius);
}

cEntity @G_SpawnIcon(int image, int team, Vec3 @origin) {
    cEntity @minimap = @G_SpawnEntity("minimap_icon");
    minimap.type = ET_MINIMAP_ICON;
    minimap.modelindex = image;
    minimap.team = team;
    minimap.setOrigin(origin);
    minimap.solid = SOLID_NOT;
    minimap.frame = 24;
    minimap.svflags |= SVF_BROADCAST;
    minimap.svflags &= ~SVF_NOCLIENT;
    return minimap;
}
