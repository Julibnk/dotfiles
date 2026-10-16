#!/bin/bash
open_and_move() {
    #$1 macos app app
    #$2 (optional) regex for the app name in yabai, when it differs from $1

    focused_app=$(yabai -m query --windows | jq -r '.[] | select(.["has-focus"] == true)')
    fapp_id=$(jq -r '.id' <<< "$focused_app")
    fapp_name=$(jq -r '.app' <<< "$focused_app")

    app_pattern="^${2:-$1}$"

    #destiny app instances
    app_instances=$(yabai -m query --windows | jq --arg re "$app_pattern" '[.[] | select((.app | test($re)) and ."is-floating" == false and ."can-move" == true)] | sort_by(.id)')
    len=$(jq '. | length' <<< "$app_instances")


    if [[ ! "$fapp_name" =~ $app_pattern || "$len" == "1" ]]; then 
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

    if [[ "$len" == "0" ]]; then
        open -a "$1"
        move_new_window_to_rule_space "$app_pattern"
    else
        # Focusing the window also switches to its space
        target_id=$(jq ".[$app_indx].id" <<< "$app_instances")
        yabai -m window --focus "$target_id"
    fi
}

move_new_window_to_rule_space() {
    # Moves the first window of a freshly opened app to the space of its yabai rule.
    # Electron and Java apps often create their window too late for the rule to apply.
    #$1 regex for the app name in yabai

    app_pattern=$1
    restarted=0
    no_handle_ticks=0

    # Wait up to 30s, since slow apps like DBeaver take a while to show a window
    for i in $(seq 1 150); do
        windows=$(yabai -m query --windows | jq --arg re "$app_pattern" 'map(select(.app | test($re))) | sort_by(.id)')
        window_id=$(jq '[.[] | select(."can-move" and .subrole == "AXStandardWindow")][0].id // empty' <<< "$windows")
        [[ -n "$window_id" ]] && break

        # Some apps, like Claude, show a window that yabai cannot control until it rescans on restart
        if [[ $(jq 'map(select(."has-ax-reference" | not)) | length' <<< "$windows") -gt 0 ]]; then
            no_handle_ticks=$((no_handle_ticks + 1))
        fi
        if [[ $restarted == 0 && $no_handle_ticks -ge 25 ]]; then
            yabai --restart-service
            restarted=1
            sleep 2
        fi
        sleep 0.2
    done
    [[ -z "$window_id" ]] && return

    app_name=$(jq -r --argjson id "$window_id" '.[] | select(.id == $id).app' <<< "$windows")
    rule_space=$(yabai -m rule --list | jq -r --arg app "$app_name" 'map(select(.app != "" and .space > 0 and (.app as $re | $app | test($re)))) | .[0].space // empty')
    [[ -z "$rule_space" ]] && return

    window_space=$(yabai -m query --windows --window "$window_id" | jq '.space')
    if [[ "$window_space" != "$rule_space" ]]; then
        yabai -m window "$window_id" --space "$rule_space"
    fi
    yabai -m window --focus "$window_id"
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
    elif [[ $current_app == "Zoom" ]]; then
        space="zoom"
    elif [[ $current_app == "Slack" ]]; then
        space="chat"
    elif [[ $current_app == "Claude" ]]; then
        space="other"
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
    elif [[ $current_app == "ZenNotes" ]]; then
        space="notes"
    elif [[ $current_app == "pgAdmin 4" ]]; then
        space="other"
    elif [[ $current_app == DBeaver* ]]; then
        space="bd"
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
