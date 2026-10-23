#!/usr/bin/env bash
THEME="$HOME/.config/rofi/wifi.rasi"

ic_on=$'\U000f05a9'
ic_off=$'\U000f05aa'
ic_lock=$'\U000f033e'
ic_ok=$'\U000f012c'
ic_scan=$'\U000f0450'
ic_cog=$'\U000f0493'
s4=$'\U000f0928'
s3=$'\U000f0925'
s2=$'\U000f0922'
s1=$'\U000f091f'

esc() { printf '%s' "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'; }
note() { notify-send -a "Wi-Fi" "Wi-Fi" "$1"; }

signal_icon() {
    if   [ "$1" -ge 75 ]; then printf '%s' "$s4"
    elif [ "$1" -ge 50 ]; then printf '%s' "$s3"
    elif [ "$1" -ge 25 ]; then printf '%s' "$s2"
    else printf '%s' "$s1"; fi
}

quality() {
    if   [ "$1" -ge 80 ]; then printf 'Excellent'
    elif [ "$1" -ge 60 ]; then printf 'Good'
    elif [ "$1" -ge 40 ]; then printf 'Fair'
    else printf 'Weak'; fi
}

sub() { printf "<span size='small' alpha='65%%'>%s</span>" "$1"; }

# Wi-Fi off: offer to turn it on
if [ "$(nmcli radio wifi)" = "disabled" ]; then
    pick=$(printf '%s\0' "$ic_on  Turn Wi-Fi on"$'\n'"$(sub 'Wi-Fi is currently off')" \
        | rofi -dmenu -markup-rows -sep '\0' -eh 2 -p "Wi-Fi" -mesg "Wi-Fi is off" -theme "$THEME" -theme-str 'listview { lines: 1; }')
    [ -n "$pick" ] && nmcli radio wifi on && note "Turned on"
    exit 0
fi

nmcli device wifi rescan >/dev/null 2>&1

ssids=(); secs=(); actives=(); rows=()
connected=""
declare -A seen

while IFS='|' read -r inuse sig rate sec ssid; do
    [ -z "$ssid" ] && continue
    [ -n "${seen[$ssid]}" ] && continue
    seen[$ssid]=1
    ssids+=("$ssid"); secs+=("$sec"); actives+=("$inuse")
    [ "$inuse" = "*" ] && connected="$ssid"

    mark=""
    [ -n "$sec" ] && [ "$sec" != "--" ] && mark="  $ic_lock"
    [ "$inuse" = "*" ] && mark="$mark  $ic_ok"

    rows+=("$(signal_icon "$sig")  <b>$(esc "$ssid")</b>$mark"$'\n'"$(sub "Range: $(quality "$sig") ($sig%) • Speed: $rate")")
done < <(nmcli -t --escape no -f IN-USE,SIGNAL,RATE,SECURITY,SSID device wifi list \
    | awk -F: '{ssid=substr($0,length($1)+length($2)+length($3)+length($4)+5); print $1"|"$2"|"$3"|"$4"|"ssid}')

n=${#ssids[@]}
rows+=("$ic_scan  <b>Rescan</b>"$'\n'"$(sub 'Refresh the network list')")
rows+=("$ic_off  <b>Turn Wi-Fi off</b>"$'\n'"$(sub 'Disconnect and disable Wi-Fi')")
rows+=("$ic_cog  <b>Advanced settings</b>"$'\n'"$(sub 'Open the network editor')")

if [ -n "$connected" ]; then
    mesg="$ic_ok  Connected to <b>$(esc "$connected")</b>"
else
    mesg="Not connected"
fi

idx=$(printf '%s\0' "${rows[@]}" \
    | rofi -dmenu -i -markup-rows -sep '\0' -eh 2 -p "Wi-Fi" -mesg "$mesg" -format i -theme "$THEME")
[ -z "$idx" ] && exit 0
[ "$idx" -lt 0 ] && exit 0

if [ "$idx" -ge "$n" ]; then
    case $((idx - n)) in
        0) exec "$0" ;;
        1) nmcli radio wifi off && note "Turned off" ;;
        2) kitty -e nmtui ;;
    esac
    exit 0
fi

ssid="${ssids[$idx]}"
sec="${secs[$idx]}"

# connected network: disconnect
if [ "${actives[$idx]}" = "*" ]; then
    nmcli connection down id "$ssid" >/dev/null 2>&1 && note "Disconnected from $ssid"
    exit 0
fi

if nmcli -t -f NAME connection show | grep -Fxq -- "$ssid"; then
    out=$(nmcli connection up id "$ssid" 2>&1)
elif [ -z "$sec" ] || [ "$sec" = "--" ]; then
    out=$(nmcli device wifi connect "$ssid" 2>&1)
else
    pass=$(rofi -dmenu -password -p "Password" -theme "$THEME" \
        -mesg "<b>$(esc "$ssid")</b>"$'\n'"Secured with $(esc "$sec")" \
        -theme-str 'listview { enabled: false; } mainbox { children: [inputbar, message]; }' < /dev/null)
    [ -z "$pass" ] && exit 0
    out=$(nmcli device wifi connect "$ssid" password "$pass" 2>&1)
fi

if [ $? -eq 0 ]; then
    note "Connected to $ssid"
else
    note "Could not connect to $ssid"
fi
