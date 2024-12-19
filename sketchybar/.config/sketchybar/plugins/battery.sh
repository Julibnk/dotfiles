#!/bin/sh

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

BATT_PERCENT=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
IS_CHARGING=$(pmset -g batt | grep 'AC Power')

if [[ $IS_CHARGING == "" ]]; then
	case ${BATT_PERCENT} in
	100)
		ICON=${ICONS_BATTERY[10]}
		COLOR=$GREEN
		;;
	9[0-9])
		ICON=${ICONS_BATTERY[9]}
		COLOR=$GREEN
		;;
	8[0-9])
		ICON=${ICONS_BATTERY[8]}
		COLOR=$GREEN
		;;
	7[0-9])
		ICON=${ICONS_BATTERY[7]}
		COLOR=$GREEN
		;;
	6[0-9])
		ICON=${ICONS_BATTERY[6]}
		COLOR=$YELLOW
		;;
	5[0-9])
		ICON=${ICONS_BATTERY[5]}
		COLOR=$YELLOW
		;;
	4[0-9])
		ICON=${ICONS_BATTERY[4]}
		COLOR=$ORANGE
		;;
	3[0-9])
		ICON=${ICONS_BATTERY[3]}
		COLOR=$ORANGE
		;;
	2[0-9])
		ICON=${ICONS_BATTERY[2]}
		COLOR=$RED
		;;
	1[0-9])
		ICON=${ICONS_BATTERY[1]}
		COLOR=$RED
		;;
	*)
		ICON=${ICONS_BATTERY[0]}
		COLOR=$RED
		;;
	esac
else
	case ${BATT_PERCENT} in
	100)
		ICON=${ICONS_BATTERY_CHARGING[10]}
		;;
	9[0-9])
		ICON=${ICONS_BATTERY_CHARGING[9]}
		;;
	8[0-9])
		ICON=${ICONS_BATTERY_CHARGING[8]}
		;;
	7[0-9])
		ICON=${ICONS_BATTERY_CHARGING[7]}
		;;
	6[0-9])
		ICON=${ICONS_BATTERY_CHARGING[6]}
		;;
	5[0-9])
		ICON=${ICONS_BATTERY_CHARGING[5]}
		;;
	4[0-9])
		ICON=${ICONS_BATTERY_CHARGING[4]}
		;;
	3[0-9])
		ICON=${ICONS_BATTERY_CHARGING[3]}
		;;
	2[0-9])
		ICON=${ICONS_BATTERY_CHARGING[2]}
		;;
	1[0-9])
		ICON=${ICONS_BATTERY_CHARGING[1]}
		;;
	*)
		ICON=${ICONS_BATTERY_CHARGING[0]}
		;;
	esac
	COLOR=$GREEN
fi

# The item invoking this script (name $NAME) will get its icon and label
# updated with the current battery status
sketchybar --set battery icon=$ICON \
	icon.color=$COLOR \
	label="${BATT_PERCENT}%" \
	label.color=$COLOR

