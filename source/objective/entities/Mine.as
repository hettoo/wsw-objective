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

const int MINE_THROW_SPEED = 300;
const float MINE_TIME = 20.0f;
const float MINE_SPEED = 0.015f;
const int MINE_RADIUS = 60;
const int MINE_EFFECT_RADIUS = 260;
const float MINE_WAIT_LIMIT = 20.0f;
const int MINE_DEFUSE_ARMOR = 70;

const Sound MINE_SPAWN_SOUND("items/item_spawn");
const Sound MINE_ARM_SOUND("misc/timer_bip_bip");
const float ATTN_MINE = 1.8f;

const Model MINE_MODEL("objects/misc/bomb_centered");
Vec3 MINE_MINS(-16, -16, -16);
Vec3 MINE_MAXS(16, 16, 40);

enum MineState {
    MS_PLACED,
    MS_PLANTED
}

class Mine {
    cEntity @ent;

    Vec3 origin;
    Vec3 angles;
    Player @owner;

    int team;
    int state;
    float progress;
    float explodeTime;
    float notArmed;

    Mine(Vec3 origin, Vec3 angles, Player @owner) {
        this.origin = origin;
        this.angles = angles;
        @this.owner = owner;

        team = owner.getTeam();
        state = MS_PLACED;
        progress = 0;
        notArmed = 0;

        spawn();
    }

    int getTeam() {
        return team;
    }

    void spawn() {
        @ent = G_SpawnEntity("mine");
        ent.type = ET_GENERIC;
        ent.modelindex = MINE_MODEL.get();
        ent.origin = origin;
        ent.angles = angles;
        @ent.owner = owner.getEnt();
        Vec3 dir, dir2, dir3;
        angles.angleVectors(dir, dir2, dir3);
        ent.velocity = ent.owner.velocity + dir * MINE_THROW_SPEED;
        ent.team = team;
        ent.setSize(MINE_MINS, MINE_MAXS);
        ent.solid = SOLID_NOT;
        ent.moveType = MOVETYPE_TOSS;
        ent.svflags &= ~SVF_NOCLIENT;
        ent.linkEntity();
        G_Sound(ent, CHAN_ITEM, MINE_SPAWN_SOUND.get(), ATTN_ITEM_SPAWN);
    }

    void remove() {
        ent.unlinkEntity();
        ent.freeEntity();
        @ent = null;
        mineSet.remove(this);
    }

    void explode() {
        ent.explosionEffect(MINE_EFFECT_RADIUS);
        ent.splashDamage(@ent.owner, MINE_EFFECT_RADIUS, 90, 50, 1,
                MOD_EXPLOSIVE);
        remove();
    }

    bool near(cEntity @other) {
        return utils.near(ent, other, MINE_RADIUS);
    }

    bool near(Player @player) {
        return near(player.getEnt());
    }

    bool nearSelfTeam(Player @player) {
        return player.getClient().team == team && near(player);
    }

    bool nearOtherTeam(Player @player) {
        return player.getClient().team != team && near(player);
    }

    void plantProgress() {
        progress += MINE_SPEED * frameTime;
    }

    void planted() {
        progress = PROGRESS_FINISHED;
        state = MS_PLANTED;
        G_Sound(ent, CHAN_ITEM, MINE_ARM_SOUND.get(), ATTN_MINE);
        explodeTime = MINE_TIME;
    }

    void defuseProgress() {
        progress -= MINE_SPEED * frameTime;
    }

    void defused(Player @defuser) {
        remove();
    }

    void thinkPlaced() {
        bool madeProgress = false;
        for (int i = 0; i < players.getSize(); i++) {
            Player @player = players.get(i);
            if (@player != null && nearSelfTeam(player)) {
                if (player.getClassId() == CLASS_ENGINEER) {
                    if (progress >= PROGRESS_FINISHED)
                        planted();
                    else 
                        plantProgress();
                    notArmed = 0;
                    madeProgress = true;
                }
                player.setHUDStat(STAT_PROGRESS_SELF, progress);
            }
        }
        if (!madeProgress) {
            notArmed += 0.001 * frameTime;
            if (notArmed > MINE_WAIT_LIMIT)
                remove();
        }
    }

    void thinkPlanted() {
        for (int i = 0; i < players.getSize(); i++) {
            Player @player = players.get(i);
            if (@player != null && nearOtherTeam(player))
                explode();
        }
    }

    void think() {
        switch (state) {
            case MS_PLACED:
                thinkPlaced();
                break;
            case MS_PLANTED:
                thinkPlanted();
                break;
        }
    }
}
