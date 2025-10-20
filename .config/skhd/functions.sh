#!/bin/bash
open_and_move() {
if [ -n "$2" ]; then
    open -a "$1" && yabai -m window --focus "$(yabai -m query --windows | jq "[.[] | select(.app==\"$2\") | select(.\"is-floating\"==false)][0].id")"
else 
    open -a "$1" && yabai -m window --focus "$(yabai -m query --windows | jq "[.[] | select(.app==\"$1\") | select(.\"is-floating\"==false)][0].id")"
fi
}

# FIX: fixfixfixfix
#
# open_browser() {
#     brave_id = $(yabai -m query --windows | jq "[.[] | select(.app==\"Brave Browser\")][0].id")
#
#     if [ -z "$brave_id" ]; then
#         open -a "Brave Browser" && yabai -m window --focus "$(yabai -m query --windows | jq "[.[] | select(.app==\"Brave Browser\")][0].id")"
#     else;
#         open -a "Zen" && yabai -m window --focus "$(yabai -m query --windows | jq "[.[] | select(.app==\"Zen\")][0].id")"
#     fi
# }

switch_yabai_layout() {
    current_layout=$(yabai -m query --spaces --space | jq -r '.type')

    if [ "$current_layout" = "bsp" ]; then
        yabai -m space --layout stack
    elif [ "$current_layout" = "stack" ]; then
        yabai -m space --layout bsp
    else
        yabai -m space --layout bsp
    fi
}

hook_back() {
    current_app=$(yabai -m query --windows | jq -r '.[] | select(.["has-focus"] == true).app')
    space=5
    if [[ $current_app == "Ghostty" ]]; then
        space="code"
    elif [[ $current_app == "kitty" ]]; then
        space="code"
    elif [[ $current_app == "Zen" ]]; then
        space="browser"
    elif [[ $current_app == "Brave Browser" ]]; then
        space="browser"
    elif [[ $current_app == "Microsoft Teams" ]]; then
        space="chat"
    elif [[ $current_app == "Obsidian" ]]; then
        space="notes"
    elif [[ $current_app == "Notion" ]]; then
        space="other"
    elif [[ $current_app == "Spotify" ]]; then
        space="music"
    elif [[ $current_app == "Postman" ]]; then
        space="other"
    elif [[ $current_app == "pgAdmin 4" ]]; then
        space="other"
    elif [[ $current_app == "Microsoft Outlook" ]]; then
        space="other"
    fi
    yabai -m window --space "$space"; yabai -m space --focus "$space";
 }

focus_prev() {

    space_type=$(yabai -m query --spaces --space | jq '.["type"]')

    if [[ "$space_type" == "\"stack\"" ]]; then
        current_stack=$(yabai -m query --windows --space | jq '.[0].["stack-index"]')
        win_total=$(yabai -m query --windows --space | jq '. | length')

        if [[ "$current_stack" == "1" ]]; then 
            yabai -m window --focus stack.last
        else
            yabai -m window --focus stack.prev
        fi
    else
       first_window=$(yabai -m query --spaces --window | jq '.[0].["first-window"]')
       current_window=$(yabai -m query --windows --window | jq '.["id"]')

       if [[ "$first_window" == "$current_window" ]]; then 
         yabai -m window --focus last
       else
         yabai -m window --focus prev
       fi
    fi
}

focus_next() {
    space_type=$(yabai -m query --spaces --space | jq '.["type"]')

    if [[ "$space_type" == "\"stack\"" ]]; then
        current_stack=$(yabai -m query --windows --space | jq '.[0].["stack-index"]')
        win_total=$(yabai -m query --windows --space | jq '. | length')

        if [[ "$current_stack" == "$win_total" ]]; then 
            yabai -m window --focus stack.first
        else
            yabai -m window --focus stack.next
        fi
    else
       first_window=$(yabai -m query --spaces --window | jq '.[0].["last-window"]')
       current_window=$(yabai -m query --windows --window | jq '.["id"]')

       if [[ "$first_window" == "$current_window" ]]; then 
         yabai -m window --focus first
       else
         yabai -m window --focus next
       fi
    fi
}
