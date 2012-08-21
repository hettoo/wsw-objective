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

const String SECTION_PREFIX = "!";

class Parser {
    Processor@[] processors;

    String byte;
    int brackets;
    bool bracketed;
    bool special;
    bool parsingSection;
    String @sectionName;
    String@[] targets;
    bool parsingMethod;
    bool parsingArguments;
    uint parsedArguments;
    String@[] arguments;
    String @method;

    Parser(Processor @mainProcessor) {
        pushProcessor(mainProcessor);
    }

    void reset() {
        brackets = 0;
        bracketed = false;
        special = false;
        parsingSection = false;
        @method = "";
        parsingArguments = false;
        parsedArguments = 0;
    }

    void pushProcessor(Processor @processor) {
        if (@processor != null)
            processor.setParser(this);
        processors.insertLast(processor);
    }

    void popProcessor() {
        processors.removeLast();
    }

    bool parseIgnored() {
        return utils.isNewline(byte);
    }

    Processor @getProcessor() {
        uint i = processors.length - 1;
        while (@processors[i] == null)
            i--;
        return processors[i];
    }

    String @preProcess(String argument, bool bracketed, bool isMethod) {
        for (uint i = processors.length; i >= 1; i--) {
            uint index = i - 1;
            if (@processors[index] != null) {
                String @newArgument = processors[index].preProcess(argument,
                        bracketed, isMethod);
                if (@newArgument != null)
                    return newArgument;
            }
        }
        return argument;
    }

    void enterSection() {
        Processor @newProcessor = getProcessor().subProcessor(sectionName);
        if (@newProcessor == null)
            utils.debug("Unknown section: " + sectionName);
        else
            newProcessor.startProcessor();
        pushProcessor(newProcessor);
    }

    void leaveSection() {
        Processor @last = processors[processors.length - 1];
        if (@last != null)
            last.stopProcessor();
        popProcessor();
    }

    void cleanMethod() {
        @method = "";
        targets.resize(0);
        arguments.resize(0);
    }

    void executeMethod() {
        for (uint i = processors.length; i >= 1; i--) {
            uint index = i - 1;
            if (@processors[index] != null
                    && processors[index].process(targets, method, arguments)) {
                cleanMethod();
                return;
            }
        }
        String message = "Could not execute method: ";
        for (uint i = 0; i < targets.length; i++)
            message += (i == 0 ? "" : ".") + targets[i];
        if (targets.length > 0)
            message += ".";
        message += method;
        for (uint i = 0; i < arguments.length; i++)
            message += " " + arguments[i];
        utils.debug(message);
        cleanMethod();
    }

    bool parseSection() {
        if (byte == "[") {
            enterSection();
        } else if (byte == "]" && processors.length > 1) {
            leaveSection();
        } else if (parsingSection) {
            if (utils.isWhitespace(byte))
                parsingSection = false;
            else
                sectionName += byte;
        } else if (byte == SECTION_PREFIX) {
            @sectionName = "";
            parsingSection = true;
        } else {
            return false;
        }
        return true;
    }

    void preProcessArgument() {
        arguments[parsedArguments] = preProcess(arguments[parsedArguments],
                bracketed, false);
        bracketed = false;
    }

    bool parseArguments() {
        if (!parsingArguments)
            return false;

        if (arguments.size() < parsedArguments + 1) {
            arguments.resize(parsedArguments + 1);
            @arguments[parsedArguments] = "";
        }

        if (byte == "{") {
            if (special) {
                if (brackets == 1)
                    arguments[parsedArguments] += byte;
                else
                    arguments[parsedArguments] += "\\" + byte;
                special = false;
            } else {
                if (arguments[parsedArguments] == "")
                    bracketed = true;
                brackets++;
            }
        } else if (brackets > 0) {
            if (special) {
                if (byte == "}") {
                    if (brackets == 1)
                        arguments[parsedArguments] += byte;
                    else
                        arguments[parsedArguments] += "\\" + byte;
                } else if (byte == "n") {
                    arguments[parsedArguments] += "\n";
                } else {
                    arguments[parsedArguments] += byte;
                }
                special = false;
            } else {
                if (byte == "\\")
                    special = true;
                else if (byte == "}")
                    brackets--;
                if (brackets > 0 && !special)
                    arguments[parsedArguments] += byte;
            }
        } else if (utils.isWhitespace(byte)) {
            preProcessArgument();
            parsedArguments++;
        } else if (byte == ";") {
            preProcessArgument();
            executeMethod();
            parsingArguments = false;
        } else {
            arguments[parsedArguments] += byte;
        }
        return true;
    }

    void stopMethodParsing() {
        parsingMethod = false;
        method = preProcess(method, false, true);
    }

    bool parseMethod() {
        if (parsingMethod || byte.isAlphaNumerical()) {
            parsingMethod = true;
            if (byte == ".") {
                targets.insertLast(method);
                @method = "";
            } else if (byte == ";") {
                stopMethodParsing();
                executeMethod();
            } else if (utils.isWhitespace(byte)) {
                stopMethodParsing();
                parsingArguments = true;
                parsedArguments = 0;
            } else {
                method += byte;
            }
            return true;
        }
        return false;
    }

    void parse(String code) {
        reset();
        processors[0].startProcessor();
        for (uint i = 0; i < code.length(); i++) {
            byte = code.subString(i, 1);
            if (!parseIgnored() && !parseArguments() && !parseSection()
                    && !parseMethod()) {
                // whatever
            }
        }
        processors[0].stopProcessor();
    }

    Callback @createCallback(String code) {
        return Callback(processors, code);
    }

    void executeCallback(Callback @callback) {
        if (@callback == null)
            return;

        Processor@[] oldProcessors;
        oldProcessors.resize(processors.size());
        for (uint i = 0; i < processors.size(); i++)
            @oldProcessors[i] = processors[i];
        Processor@[] processors = callback.getProcessors();
        this.processors.resize(processors.size());
        for (uint i = 0; i < processors.size(); i++)
            @this.processors[i] = processors[i];

        parse(callback.getCode());

        this.processors.resize(oldProcessors.size());
        for (uint i = 0; i < oldProcessors.size(); i++)
            @this.processors[i] = oldProcessors[i];
    }
}
