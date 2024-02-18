#!/bin/bash

# Settings
dac_state_file=/proc/asound/card0/pcm0p/sub0/hw_params
target_source="Main.Source=1"
idlecount=0
target_tty="/dev/ttyUSB0"
ttl=8

# Logic starts here
/bin/stty -F $target_tty 115200

let dacActive=0
let idlecount=0

for (( ; ; ))
    do
        state=$(/usr/bin/nad_command $target_tty "Main.Power?" 3)
        sleep 2
        source=$(/usr/bin/nad_command $target_tty "Main.Source?" 5)
        if [[ $source =~ "$target_source" ]]; then
            if grep -q "closed" $dac_state_file; then
                let "idlecount++"
                dacActive=0
                echo "DAC IDLE for $idlecount cycle(s)"
            else
                echo "DAC Playing"
                dacActive=1
                idlecount=0
            fi
            if [[ $idlecount -ge $ttl ]]; then
                if [[ $state =~ "Main.Power=On" ]]; then
                    echo "Amp Off"
                    /usr/bin/nad_command $target_tty "Main.Power=Off" 3
                fi
                idlecount=0
            else
                if [ $dacActive -eq 1 ] && [[ $state =~ "Main.Power=Off" ]]; then
                    echo "Amp ON"
                    /usr/bin/nad_command $target_tty "Main.Power=On" 3
                fi
            fi
        else
            echo "Source not set to Optical 1 but to $source. Not doing any checks."
        fi
    sleep 1
done
