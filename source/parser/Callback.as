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

class Callback {
    Processor@[] processors;
    String @code;

    Callback(Processor@[] processors, String code) {
        this.processors.resize(processors.size());
        for (uint i = 0; i < processors.size(); i++)
            @this.processors[i] = processors[i];
        @this.code = code;
    }

    Processor@[] getProcessors() {
        return processors;
    }

    String @getCode() {
        return code;
    }
}
