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
const float ARMOR_FRAME_BONUS = 0.002f;

const int SPAWN_PROTECTION_TIME = 3;

const Sound AMMOPACK_DROP_SOUND("items/ammo_pickup");
const Sound HEALTHPACK_DROP_SOUND("items/health_5");

class Player {
    cClient @client;
    cEntity @ent;

    float score;

    Class @playerClass;
    int currentClass;
    int nextClass;

    Players @players;
    Classes @classes;

    Player(Players @players) {
        score = 0;

        currentClass = CLASS_SOLDIER;
        nextClass = CLASSES;

        @this.players = players;
        @this.classes = players.getClasses();

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

    Players @getPlayers() {
        return players;
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

    cString @getClassName() {
        return playerClass.getName();
    }

    int getTeam() {
        return client.team;
    }

    void centerPrint(cString &msg) {
        G_CenterPrintMsg(ent, msg);
    }

    void setClass(int newClass) {
        if (newClass >= 0 && newClass < CLASSES) {
            nextClass = newClass;
            centerPrint("You will respawn as a "
                    + classes.get(nextClass).getName());
        }
    }

    void setClass(cString &newClass) {
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

    void giveAmmo(int weapon, int strongAmmo, int weakAmmo) {
        cItem @item = G_GetItem(weapon);

        if (client.canSelectWeapon(weapon)) {
            strongAmmo += client.inventoryCount(item.ammoTag);
            weakAmmo += client.inventoryCount(item.weakAmmoTag);
        } else {
            client.inventoryGiveItem(weapon);
        }

        client.inventorySetCount(item.ammoTag, strongAmmo);
        client.inventorySetCount(item.weakAmmoTag, weakAmmo);
    }

    bool giveAmmo(int weapon, int strongAmmo, int maxStrongAmmo, int weakAmmo,
            int maxWeakAmmo) {
        if (client.canSelectWeapon(weapon)) {
            cItem @item = G_GetItem(weapon);
            int currentWeakAmmo = client.inventoryCount(item.weakAmmoTag);
            int currentStrongAmmo = client.inventoryCount(item.ammoTag);

            if (currentWeakAmmo >= maxWeakAmmo
                    && currentStrongAmmo >= maxStrongAmmo)
                return false;

            if (currentWeakAmmo + weakAmmo > maxWeakAmmo)
                weakAmmo = maxWeakAmmo - currentWeakAmmo;
            if (currentStrongAmmo + strongAmmo > maxStrongAmmo)
                strongAmmo = maxStrongAmmo - currentStrongAmmo;
        }

        giveAmmo(weapon, strongAmmo, weakAmmo);
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
        setHUDStat(STAT_IMAGE_OTHER, 0);
        setHUDStat(STAT_MESSAGE_SELF, 0);

        GENERIC_ChargeGunblade(client);
        playerClass.addArmor(this, ARMOR_FRAME_BONUS * frameTime);
    }

    void classAction1() {
        playerClass.classAction1(this);
    }

    void classAction2() {
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

    void didDamage(cString &args) {
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

    void madeKill(cString &args) {
        cEntity @target = G_GetEntity(args.getToken(0).toInt());
        if (@target != null && @target.client != null) {
            float bonus = KILL_BONUS;
            if (target.client.team == client.team)
                bonus *= -1;
            addScore(bonus);
        }
    }
}
