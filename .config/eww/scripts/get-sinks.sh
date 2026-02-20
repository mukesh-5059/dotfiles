#!/bin/bash

pactl list sinks | awk '
    BEGIN {
        RS = ""
        FS = "\n"
        print "["
        first = 1
    }
    {
        name = ""
        description = ""
        for (i = 1; i <= NF; i++) {
            if ($i ~ /^\s*Name: /) {
                sub(/^\s*Name: /, "", $i)
                name = $i
            }
            if ($i ~ /^\s*Description: /) {
                sub(/^\s*Description: /, "", $i)
                description = $i
            }
        }
        if (name != "" && description != "") {
            if (!first) {
                print ","
            }
            first = 0
            gsub(/"/, "\\\"", description)
            gsub(/"/, "\\\"", name)
            printf "{\"name\":\"%s\",\"description\":\"%s\"}", name, description
        }
    }
    END {
        print "\n]"
    }
'
