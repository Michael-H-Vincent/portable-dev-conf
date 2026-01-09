#!/bin/bash

# Paths to your wallpaper images
MORNING_WALLPAPER=~/.config/hypr/wallpapers/tropic_islands/tropic_island_morning.jpg
DAY_WALLPAPER=~/.config/hypr/wallpapers/tropic_islands/tropic_island_day.jpg
EVENING_WALLPAPER=~/.config/hypr/wallpapers/tropic_islands/tropic_island_evening.jpg
NIGHT_WALLPAPER=~/.config/hypr/wallpapers/tropic_islands/tropic_island_night.jpg

# Get the current hour (24-hour format)
HOUR=$(date +%H)

# Select wallpaper based on time range
if [ $HOUR -ge 6 ] && [ $HOUR -lt 11 ]; then
    WALLPAPER=$MORNING_WALLPAPER
elif [ $HOUR -ge 11 ] && [ $HOUR -lt 18 ]; then
    WALLPAPER=$DAY_WALLPAPER
elif [ $HOUR -ge 18 ] && [ $HOUR -lt 21 ]; then
    WALLPAPER=$EVENING_WALLPAPER
else
    WALLPAPER=$NIGHT_WALLPAPER
fi

# Preload and set the wallpaper on your monitor (replace e.g. eDP-1 with your monitor name)
hyprctl hyprpaper preload "$WALLPAPER"
hyprctl hyprpaper wallpaper "eDP-1,$WALLPAPER"
hyprctl hyprpaper unload unused
