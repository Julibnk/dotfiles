#!/bin/bash
open_and_move() {
    #$1 macos app app
    #$2 (optional) app name when its started .app in yabai

    focused_app=$(yabai -m query --windows | jq -r '.[] | select(.["has-focus"] == true)')
    fapp_id=$(jq -r '.id' <<< "$focused_app")
    fapp_name=$(jq -r '.app' <<< "$focused_app")

    if [ -n "$2" ]; then
        app_name=$2
    else 
        app_name=$1
    fi

    #destiny app instances
    app_instances=$(yabai -m query --windows | jq -r "[.[] | select(.app==\"$app_name\") | select(.\"is-floating\"==false and .\"can-move\"==true)] | sort_by(.id)")
    len=$(jq '. | length' <<< "$app_instances")


    if [[ "$app_name" != "$fapp_name" || "$len" == "1" ]]; then 
        #the app is not the same or there is only one instance, so index 0
        echo "different app or just one instance"
        app_indx=0
    else 

        echo "more than one instance"
        fapp_index=$(jq --arg id "$fapp_id" 'map(.id) | index($id|tonumber)' <<< "$app_instances")
        len=$((len - 1))
        if [[ $fapp_index -eq $len ]]; then
            app_indx=0
        else
            app_indx=$((fapp_index + 1))
        fi
        echo $app_indx
    fi

    open -a "$1" && yabai -m window --focus "$(jq ".[$app_indx].id" <<< "$app_instances")"
}

open_terminal() {
    #$1 macos app app
    #$2 instance number

    app_name=$1
    app_indx=$2

    app_instances=$(yabai -m query --windows | jq -r "[.[] | select(.app==\"$app_name\") | select(.\"is-floating\"==false and .\"can-move\"==true)] | sort_by(.id)")
    len=$(jq '. | length' <<< "$app_instances")

    if [[ "$len" -le "$app_indx" ]] then
        open -a "$1" -n
        # Wait for yabai to register the new window
        for i in $(seq 1 20); do
            sleep 0.1
            app_instances=$(yabai -m query --windows | jq -r "[.[] | select(.app==\"$app_name\") | select(.\"is-floating\"==false and .\"can-move\"==true)] | sort_by(.id)")
            new_len=$(jq '. | length' <<< "$app_instances")
            [[ "$new_len" -gt "$len" ]] && break
        done
        yabai -m window --focus "$(jq ".[$app_indx].id" <<< "$app_instances")"
    else
        yabai -m window --focus "$(jq ".[$app_indx].id" <<< "$app_instances")"
    fi

    # Update kitty letter in all tmux sessions
    for session in $(tmux list-sessions -F '#S' 2>/dev/null); do
        tmux run-shell -t "$session" "~/.tmux/kitty-letter.sh" 2>/dev/null &
    done
}

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
