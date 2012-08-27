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

const int REVIVER_RADIUS = 48;
const Model REVIVER_MODEL("objects/reviver/reviver");

class Reviver {
    Player @player;
    cEntity @ent;

    Reviver(Player @player) {
        @this.player = player;
    }

    bool spawn() {
        destroy();

        if (G_PointContents(player.ent.origin) & CONTENTS_NODROP != 0)
            return false;

        cEntity @ent = @G_SpawnEntity("reviver");
        @this.ent = @ent;

        ent.team = player.getTeam();
        ent.type = ET_GENERIC;
        ent.modelindex = REVIVER_MODEL.get();
        Vec3 mins, maxs;
        player.getEnt().getSize(mins, maxs);
        ent.setSize(mins, maxs);
        ent.solid = SOLID_TRIGGER;
        ent.clipMask = MASK_PLAYERSOLID;
        ent.moveType = MOVETYPE_TOSS;
        ent.mass = player.ent.mass;
        ent.svflags &= ~SVF_NOCLIENT;
        ent.svflags |= SVF_ONLYTEAM | SVF_BROADCAST;

        ent.origin = player.getEnt().origin;
        ent.angles = player.getEnt().angles;

        ent.linkEntity();

        return true;
    }

    Player @getTarget() {
        return player;
    }

    cEntity @getEntity() {
        return ent;
    }

    void destroy() {
        if (@ent == null)
            return;

        ent.unlinkEntity();
        ent.freeEntity();
        @ent = null;
    }

    bool near(Vec3 origin) {
        return utils.near(origin, ent.origin, REVIVER_RADIUS);
    }

    void revive() {
        player.resume();
    }

    void think() {
        if (@ent == null)
            return;

        for (int i = 0; i < players.getSize(); i++) {
            Player @player = players.get(i);
            if (@player != null && player.getTeam() == ent.team
                    && player.isAlive()) {
                if (player.getClassId() == CLASS_MEDIC) {
                    int configStringId = CS_GENERAL
                        + player.getClient().playerNum;
                    G_ConfigString(configStringId,
                            "You can revive this player");
                    player.setHUDStat(STAT_MESSAGE_SELF, configStringId);
                }
                player.setHUDStat(STAT_IMAGE_OTHER,
                        classes.getIcon(CLASS_MEDIC));
            }
        }
    }
}
