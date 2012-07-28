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

const int ARTILLERY_HEIGHT = 1200;
const float ARTILLERY_MIN_WAIT = 0.05f;
const float ARTILLERY_MAX_WAIT = 3.0f;
const int ARTILLERY_ROCKETS = 14;
const int ARTILLERY_IMPACT = 300;
const float ARTILLERY_MAX_DIVERGENCY = 28.0f;

class Artillery {
    int id;

    Vec3 @origin;
    Player @owner;
    int rocketsFired;
    float wait;

    Artillery(Vec3 @origin, Player @owner, int id) {
        this.id = id;

        @this.origin = origin;
        this.origin.z += ARTILLERY_HEIGHT;
        @this.owner = owner;

        rocketsFired = 0;
        setNextLaunch();
    }

    void setNextLaunch() {
        wait = brandom(ARTILLERY_MIN_WAIT, ARTILLERY_MAX_WAIT);
    }

    void launch() {
        Vec3 thisOrigin = origin;
        Vec3 angles(2 * brandom(0, ARTILLERY_MAX_DIVERGENCY)
                - ARTILLERY_MAX_DIVERGENCY + 90,
                4 * (2 * brandom(0, ARTILLERY_MAX_DIVERGENCY)
                - ARTILLERY_MAX_DIVERGENCY), 0);

        G_FireRocket(origin, angles, 1500, ARTILLERY_IMPACT, ARTILLERY_IMPACT,
                ARTILLERY_IMPACT, 1, owner.getEnt());

        if (++rocketsFired == ARTILLERY_ROCKETS)
            artillerySet.remove(id);
    }

    void think() {
        wait -= 0.001f * frameTime;

        if (wait <= 0) {
            launch();
            setNextLaunch();
        }
    }
}
