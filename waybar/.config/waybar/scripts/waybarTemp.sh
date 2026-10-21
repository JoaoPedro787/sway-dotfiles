#!/usr/bin/env bash

## Script  : waybarTemp.sh
## Purpose : Return CPU temperature in JSON format for Waybar (supports badge, icon, and simple modes)

MODE="${1:-simple}"

get_cpu_temp() {
  local temp_raw=""

  # 1. Hardware monitoring (hwmon) - Prioridade para drivers oficiais de CPU (Intel / AMD)
  for hw in /sys/class/hwmon/hwmon*; do
    [ -d "$hw" ] || continue
    local name=""
    [ -r "$hw/name" ] && name=$(cat "$hw/name" 2>/dev/null)

    case "$name" in
      coretemp) # Intel: Package id 0 ou Core
        # Prioridade para o pacote global da CPU
        for lbl in "$hw"/temp*_label; do
          [ -r "$lbl" ] || continue
          local label_val
          label_val=$(cat "$lbl" 2>/dev/null)
          if [[ "$label_val" =~ [Pp]ackage\ id ]]; then
            local input="${lbl%_label}_input"
            if [ -r "$input" ]; then
              temp_raw=$(cat "$input" 2>/dev/null)
              if [[ -n "$temp_raw" && "$temp_raw" -gt 0 ]]; then
                echo $(( (temp_raw + 500) / 1000 ))
                return 0
              fi
            fi
          fi
        done
        # Fallback dentro de coretemp: temp1_input ou outro sensor
        for input in "$hw"/temp*_input; do
          [ -r "$input" ] || continue
          temp_raw=$(cat "$input" 2>/dev/null)
          if [[ -n "$temp_raw" && "$temp_raw" -gt 0 ]]; then
            echo $(( (temp_raw + 500) / 1000 ))
            return 0
          fi
        done
        ;;

      k10temp|zenpower) # AMD: Tctl ou Tdie
        for lbl in "$hw"/temp*_label; do
          [ -r "$lbl" ] || continue
          local label_val
          label_val=$(cat "$lbl" 2>/dev/null)
          if [[ "$label_val" =~ (Tctl|Tdie) ]]; then
            local input="${lbl%_label}_input"
            if [ -r "$input" ]; then
              temp_raw=$(cat "$input" 2>/dev/null)
              if [[ -n "$temp_raw" && "$temp_raw" -gt 0 ]]; then
                echo $(( (temp_raw + 500) / 1000 ))
                return 0
              fi
            fi
          fi
        done
        if [ -r "$hw/temp1_input" ]; then
          temp_raw=$(cat "$hw/temp1_input" 2>/dev/null)
          if [[ -n "$temp_raw" && "$temp_raw" -gt 0 ]]; then
            echo $(( (temp_raw + 500) / 1000 ))
            return 0
          fi
        fi
        ;;

      *cpu*) # Outros drivers de CPU
        for input in "$hw"/temp*_input; do
          [ -r "$input" ] || continue
          temp_raw=$(cat "$input" 2>/dev/null)
          if [[ -n "$temp_raw" && "$temp_raw" -gt 0 ]]; then
            echo $(( (temp_raw + 500) / 1000 ))
            return 0
          fi
        done
        ;;
    esac
  done

  # 2. Thermal zones específicas de CPU (/sys/class/thermal)
  for tz in /sys/class/thermal/thermal_zone*; do
    [ -d "$tz" ] || continue
    local type=""
    [ -r "$tz/type" ] && type=$(cat "$tz/type" 2>/dev/null | tr '[:upper:]' '[:lower:]')
    if [[ "$type" == *"pkg_temp"* || "$type" == *"cpu"* || "$type" == *"k10temp"* || "$type" == "tcpu" ]]; then
      if [ -r "$tz/temp" ]; then
        temp_raw=$(cat "$tz/temp" 2>/dev/null)
        if [[ -n "$temp_raw" && "$temp_raw" -gt 0 ]]; then
          echo $(( (temp_raw + 500) / 1000 ))
          return 0
        fi
      fi
    fi
  done

  # 3. Fallback para comando lm_sensors se instalado
  if command -v sensors &>/dev/null; then
    local s_temp
    s_temp=$(sensors 2>/dev/null | grep -m 1 -E "(Package id|Tctl|Tdie|CPU Temperature|Core 0)" | awk -F: '{print $2}' | tr -dc '0-9.' | cut -d. -f1)
    if [[ -n "$s_temp" && "$s_temp" -gt 0 ]]; then
      echo "$s_temp"
      return 0
    fi
  fi

  # 4. Último recurso absoluto: thermal zones genéricas (excluindo zonas inválidas/zeradas)
  for tz in /sys/class/thermal/thermal_zone*; do
    [ -d "$tz" ] || continue
    if [ -r "$tz/temp" ]; then
      temp_raw=$(cat "$tz/temp" 2>/dev/null)
      if [[ -n "$temp_raw" && "$temp_raw" -gt 10000 ]]; then
        echo $(( (temp_raw + 500) / 1000 ))
        return 0
      fi
    fi
  done

  return 1
}

TEMP=$(get_cpu_temp)

# Fallback se nenhuma temperatura for encontrada
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
