#!/bin/bash

update() {
  source "$CONFIG_DIR/colors.sh"
  COLOR=$TRANSPARENT
  if [ "$SELECTED" = "true" ]; then
    COLOR=$KANAGAWA_DARK_YELLOW
  fi
  sketchybar --set $NAME icon.highlight=$SELECTED \
                         label.highlight=$SELECTED \
                         background.color=$COLOR
                         # background.border_color=$COLOR
}

mouse_clicked() {
  yabai -m space --focus $SID 2>/dev/null

  # if [ "$BUTTON" = "right" ]; then
  #   yabai -m space --destroy $SID
  #   sketchybar --trigger windows_on_spaces --trigger space_change
  # else
  #   yabai -m space --focus $SID 2>/dev/null
  # fi
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked
  ;;
  *) update
  ;;
esac
