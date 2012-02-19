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
const float BOMB_TIME = 30.0f;
const float BOMB_SPEED = 0.015f;
const int BOMB_RADIUS = 80;
const int BOMB_EFFECT_RADIUS = 420;
const float BOMB_WAIT_LIMIT = 20.0f;
const int BOMB_DEFUSE_ARMOR = 70;

const Model BOMB_MODEL("objects/misc/bomb_centered");
cVec3 BOMB_MINS(-16, -16, -16);
cVec3 BOMB_MAXS(16, 16, 40);

enum BombState {
    BS_PLACED,
    BS_PLANTED
}

class Bomb {
    int id;

    cEntity @ent;

    cVec3 @origin;
    cVec3 @angles;
    Player @owner;

    int team;
    int state;
    float progress;
    float timer;
    float notArmed;

    Players @players;
    BombSet @bombSet;
    ObjectiveSet @objectiveSet;

    Bomb(cVec3 @origin, cVec3 @angles, Player @owner, int id, Players @players,
            BombSet @bombSet, ObjectiveSet @objectiveSet) {
        this.id = id;

        @this.origin = origin;
        @this.angles = angles;
        @this.owner = owner;

        team = owner.getEnt().team;
        state = BS_PLACED;
        progress = 0;
        notArmed = 0;

        @this.bombSet = bombSet;
        @this.players = players;
        @this.objectiveSet = objectiveSet;
    }

    void spawn() {
        @ent = G_SpawnEntity("bomb");
        ent.type = ET_GENERIC;
        ent.modelindex = BOMB_MODEL.get();
        ent.setOrigin(origin);
        ent.setAngles(angles);
        @ent.owner = owner.getEnt();
        cVec3 dir;
        angles.angleVectors(dir, null, null);
        ent.setVelocity(ent.owner.getVelocity() + dir * BOMB_THROW_SPEED);
        ent.team = team;
        ent.setSize(BOMB_MINS, BOMB_MAXS);
        ent.solid = SOLID_NOT;
        ent.moveType = MOVETYPE_TOSS;
        ent.svflags &= ~SVF_NOCLIENT;
        ent.linkEntity();
    }

    void remove() {
        ent.unlinkEntity();
        ent.freeEntity();
        @ent = null;
        bombSet.remove(id);
    }

    void explode() {
        ent.explosionEffect(BOMB_EFFECT_RADIUS);
        ent.splashDamage(@ent.owner, BOMB_EFFECT_RADIUS, 180, 100, 1,
                MOD_EXPLOSIVE);
        objectiveSet.exploded(ent);
        remove();
    }

    bool near(cEntity @other) {
        return G_Near(ent, other, BOMB_RADIUS);
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
        progress += BOMB_SPEED * frameTime;
    }
    
    void planted() {
        progress = PROGRESS_FINISHED;
        state = BS_PLANTED;
        timer = BOMB_TIME;
        objectiveSet.planted(ent);
    }

    void defuseProgress() {
        progress -= BOMB_SPEED * frameTime;
    }

    void defused() {
        objectiveSet.defused(ent);
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
            if (notArmed > BOMB_WAIT_LIMIT)
                remove();
        }
    }

    void thinkPlanted() {
        for (int i = 0; i < players.getSize(); i++) {
            Player @player = players.get(i);
            if (@player != null && nearOtherTeam(player)) {
                if (player.getClassId() == CLASS_ENGINEER) {
                    if (progress <= 0)
                        defused();
                    else if (player.takeArmor(BOMB_SPEED * frameTime
                                / PROGRESS_FINISHED * BOMB_DEFUSE_ARMOR))
                        defuseProgress();
                }
                player.setHUDStat(STAT_PROGRESS_OTHER, progress);
            }
        }
        timer -= frameTime * 0.001;
        if (timer <= 0)
            explode();
    }

    void think() {
        switch (state) {
            case BS_PLACED:
                thinkPlaced();
                break;
            case BS_PLANTED:
                thinkPlanted();
                break;
        }
    }
}
