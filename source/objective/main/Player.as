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

const float DAMAGE_BONUS = 0.02f;
const float KILL_BONUS = 1;
const float SUICIDE_BONUS = -3;
const float ARMOR_FRAME_BONUS = 0.002f;

const int SPAWN_PROTECTION_TIME = 3;

const Sound AMMOPACK_DROP_SOUND("items/ammo_pickup");
const Sound HEALTHPACK_DROP_SOUND("items/health_5");

class Player {
    cClient @client;
    cEntity @ent;

    float score;
    Stealable @carry;
    CarryIdenticator @carryIdenticator;

    Class @playerClass;
    int currentClass;
    int nextClass;

    Player() {
        score = 0;

        currentClass = CLASS_SOLDIER;
        nextClass = CLASSES;

        loadClass();
    }

    void init(cClient @newClient) {
        @client = newClient;
        @ent = client.getEnt();
    }

    bool isBot() {
        return client.isBot();
    }

    cClient @getClient() {
        return client;
    }

    cEntity @getEnt() {
        return ent;
    }

    Stealable @getCarry() {
        return carry;
    }

    void setCarry(Stealable @carry) {
        @this.carry = carry;
        if (@carry == null) {
            carryIdenticator.destroy();
            @carryIdenticator = null;
        } else {
            @carryIdenticator = CarryIdenticator(ent);
        }
    }

    bool secureCarry(Objective @target) {
        if (@carry == null)
            return false;

        carry.secured(this, target);
        setCarry(null);
        return true;
    }

    int getClassId() {
        return currentClass;
    }

    int getClassIcon() {
        return playerClass.getIcon();
    }

    Class @getClass() {
        return playerClass;
    }

    void showGameMenu() {
        client.execGameCommand(classes.createMenu());
    }

    void setHealth(int health) {
        ent.health = health;
    }

    void setArmor(int armor) {
        client.armor = armor;
    }

    String @getClassName() {
        return playerClass.getName();
    }

    int getTeam() {
        return client.team;
    }

    void centerPrint(String &msg) {
        G_CenterPrintMsg(ent, msg);
    }

    void setClass(int newClass) {
        if (newClass >= 0 && newClass < CLASSES) {
            nextClass = newClass;
            centerPrint("You will respawn as a "
                    + classes.get(nextClass).getName());
        }
    }

    void setClass(String &newClass) {
        setClass(classes.find(newClass));
    }

    void setHUDStat(int stat, int value) {
        client.setHUDStat(stat, value);
    }

    bool takeArmor(float armor) {
        client.armor -= armor;
        if (client.armor < -0.5) {
            client.armor += armor;
            return false;
        }
        return true;
    }

    void giveItem(int item, int amount) {
        client.inventoryGiveItem(item);
        client.inventorySetCount(item, amount);
    }

    void giveAmmo(int weapon, int ammo) {
        cItem @item = G_GetItem(weapon);

        if (client.canSelectWeapon(weapon))
            ammo += client.inventoryCount(item.ammoTag);
        else
            client.inventoryGiveItem(weapon);

        client.inventorySetCount(item.ammoTag, ammo);
    }

    bool giveAmmo(int weapon, int ammo, int maxAmmo) {
        if (client.canSelectWeapon(weapon)) {
            cItem @item = G_GetItem(weapon);
            int currentAmmo = client.inventoryCount(item.ammoTag);

            if (currentAmmo >= maxAmmo)
                return false;

            if (currentAmmo + ammo > maxAmmo)
                ammo = maxAmmo - currentAmmo;
        }

        giveAmmo(weapon, ammo);
        return true;
    }

    bool giveAmmopack() {
        bool done = playerClass.giveAmmopack(this);
        if (done)
            itemPickupSound(AMMOPACK_DROP_SOUND.get());
        return done;
    }

    bool giveHealthpack() {
        bool done = playerClass.giveHealthpack(this);
        if (done)
            itemPickupSound(HEALTHPACK_DROP_SOUND.get());
        return done;
    }

    void loadClass() {
        @playerClass = classes.get(currentClass);
    }

    void applyNextClass() {
        if (nextClass < CLASSES) {
            currentClass = nextClass;
            nextClass = CLASSES;
            loadClass();
        }
    }

    void spawn() {
        applyNextClass();
        giveItem(POWERUP_SHELL, SPAWN_PROTECTION_TIME);
        playerClass.spawn(this);
        ent.respawnEffect();
    }

    void think() {
        if (client.team == TEAM_SPECTATOR)
            return;

        setHUDStat(STAT_PROGRESS_SELF, 0);
        setHUDStat(STAT_PROGRESS_OTHER, 0);
        setHUDStat(STAT_IMAGE_SELF, @carry == null
                ? 0 : carry.getObjective().getIcon());
        setHUDStat(STAT_IMAGE_OTHER, 0);
        setHUDStat(STAT_MESSAGE_SELF, 0);

        GENERIC_ChargeGunblade(client);
        if (ent.health > 0)
            playerClass.addArmor(this, ARMOR_FRAME_BONUS * frameTime);

        if (@carryIdenticator != null)
            carryIdenticator.update();
    }

    void classAction1() {
        if (client.team != TEAM_SPECTATOR)
            playerClass.classAction1(this);
    }

    void classAction2() {
        if (client.team != TEAM_SPECTATOR)
            playerClass.classAction2(this);
    }

    void itemPickupSound(int sound) {
        G_Sound(ent, CHAN_ITEM, sound, ATTN_ITEM_PICKUP);
    }

    void syncScore() {
        client.stats.setScore(score);
    }

    void addScore(float bonus) {
        score += bonus;
        syncScore();
    }

    void setScore(float score) {
        this.score = score;
    }

    bool isAlive() {
        return ent.health > 0;
    }

    void didDamage(String &args) {
        cEntity @target = G_GetEntity(args.getToken(0).toInt());
        if (@target != null && @target.client != null) {
            float bonus = args.getToken(1).toFloat() * DAMAGE_BONUS;
            if (@target != @ent) {
                if (target.client.team == client.team)
                    bonus *= -1;
                addScore(bonus);
            }
        }
    }

    void killed() {
        if (@carry != null) {
            carry.dropped(this);
            @carry = null;
        }
    }

    void madeKill(bool suicide, bool teamKill) {
        float bonus = KILL_BONUS;
        if (suicide)
            bonus = SUICIDE_BONUS;
        else if (teamKill)
            bonus *= -1;
        addScore(bonus);
    }
}
