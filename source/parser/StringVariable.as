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

class StringVariable : Variable {
    String value;

    StringVariable(String value) {
        super(value);
    }

    StringVariable() {
        super();
    }

    void set(String value) {
        this.value = value;
    }

    void add(String value) {
        this.value += value;
    }

    void equals(String value) {
        stack.insertLast(this.value == value ? "1" : "0");
    }

    void nequals(String value) {
        stack.insertLast(this.value == value ? "0" : "1");
    }

    void multiply(String value) {
        int count = value.toInt();
        String original = value;
        for (int i = 1; i < count; i++)
            this.value += original;
    }

    String @getString() {
        return value;
    }

    bool process(String method, String argument) {
        if (method == "multiply")
            multiply(argument);
        else
            return Variable::process(method, argument);
        return true;
    }
}
