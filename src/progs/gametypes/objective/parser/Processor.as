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

class Processor {
    Parser @parser;

    void startProcessor() {
    }

    void stopProcessor() {
    }

    void setParser(Parser @parser) {
        @this.parser = parser;
    }

    bool process(String@[] targets, String method, String@[] arguments) {
        if (targets.size() == 0)
            return process(method, arguments);
        else {
            Processor @subProcessor = subProcessor(targets[0]);
            if (@subProcessor != null) {
                targets.removeAt(0);
                return subProcessor.process(targets, method, arguments);
            }
        }
        return false;
    }

    bool process(String method, String@[] arguments) {
        return false;
    }

    Processor @subProcessor(String target) {
        return null;
    }
}