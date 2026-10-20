#!/usr/bin/env bash

## Script  : waybarTemp.sh
## Purpose : Return CPU temperature in JSON format for Waybar (supports badge, icon, and simple modes)

MODE="${1:-simple}"

TEMP=""

# 1. Try lm_sensors if available
if command -v sensors &>/dev/null; then
  TEMP=$(sensors | grep -m 1 'Package id 0' | awk '{print $4}' | tr -d '+°C')
  if [[ -z "$TEMP" ]]; then
    TEMP=$(sensors | grep -m 1 'edge' | awk '{print $2}' | tr -d '+°C')
  fi
fi

# 2. Fallback to /sys/class/thermal
if [[ -z "$TEMP" ]]; then
  for tz in /sys/class/thermal/thermal_zone*/temp; do
    if [[ -r "$tz" ]]; then
      raw=$(cat "$tz" 2>/dev/null)
      type_file="$(dirname "$tz")/type"
      if [[ -r "$type_file" ]]; then
        type_name=$(cat "$type_file" 2>/dev/null)
        if [[ "$type_name" == *"pkg_temp"* || "$type_name" == *"cpu"* || "$type_name" == *"acpitz"* ]]; then
          if [[ -n "$raw" && "$raw" -gt 0 ]]; then
            TEMP=$(( raw / 1000 ))
            break
          fi
        fi
      fi
      if [[ -z "$TEMP" && -n "$raw" && "$raw" -gt 1000 ]]; then
        TEMP=$(( raw / 1000 ))
      fi
    fi
  done
fi

# 3. Fallback to /sys/class/hwmon
if [[ -z "$TEMP" ]]; then
  for hw in /sys/class/hwmon/hwmon*/temp1_input; do
    if [[ -r "$hw" ]]; then
      raw=$(cat "$hw" 2>/dev/null)
      if [[ -n "$raw" && "$raw" -gt 1000 ]]; then
        TEMP=$(( raw / 1000 ))
        break
      fi
    fi
  done
fi

# Fallback if no temp found
if [[ -z "$TEMP" ]]; then
  CLASS="unknown"
  case "$MODE" in
    badge)
      FORMAT="<span color='#ebdbb2' bgcolor='#555555' >  </span> N/A°C"
      ;;
    icon)
      FORMAT="<span color='#ebdbb2'>  </span> N/A°C "
      ;;
    *)
      FORMAT="<span color='#555555' >  </span>N/A°C"
      ;;
  esac
  printf '{"text":"%s","class":"%s"}\n' "$FORMAT" "$CLASS"
  exit 0
fi

TEMP_INT=$(printf "%.0f" "$TEMP")

if (( TEMP_INT >= 70 )); then
  CLASS="critical"
  case "$MODE" in
    badge)
      FORMAT="<span color='#202020' bgcolor='#cc241d' >  </span> ${TEMP_INT}°C"
      ;;
    icon)
      FORMAT="<span color='#cc241d'>  </span>${TEMP_INT}°C"
      ;;
    *)
      FORMAT="<span color='#ebdbb2' >  </span>${TEMP_INT}°C"
      ;;
  esac
else
  CLASS="normal"
  case "$MODE" in
    badge)
      FORMAT="<span color='#202020' bgcolor='#d8a657' > 󰴈 </span> ${TEMP_INT}°C"
      ;;
    icon)
      FORMAT="<span color='#d8a657'> 󰴈 </span>${TEMP_INT}°C"
      ;;
    *)
      FORMAT="<span color='#d8a657' > 󰴈 </span>${TEMP_INT}°C"
      ;;
  esac
fi

printf '{"text":"%s","class":"%s"}\n' "$FORMAT" "$CLASS"
