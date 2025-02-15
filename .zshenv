# Helpers for non interactive shells must be here 

# Window manager helpers
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
