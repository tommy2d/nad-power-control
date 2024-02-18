#!/bin/bash

# Settings
dac_state_file=/proc/asound/card0/pcm0p/sub0/hw_params
target_source="Main.Source=1"
idlecount=0
target_tty="/dev/ttyUSB0"
ttl=20

# Logic starts here
/bin/stty -F $target_tty 115200

let idlecount=0

for (( ; ; ))
    do
        state=$(/usr/bin/nad_command $target_tty "Main.Power?" 2)
        sleep 1
        source=$(/usr/bin/nad_command $target_tty "Main.Source?" 4)
        if [[ $source =~ "$target_source" ]]; then
            if grep -q "closed" $dac_state_file; then
                let "idlecount++"
                echo "DAC IDLE for $idlecount cycle(s)"
            else
                    echo "DAC Playing"
                    idlecount=0
            fi
            if [[ $idlecount -ge $ttl ]]; then
                if [[ $state =~ "Main.Power=On" ]]; then
                    echo "Amp Off"
                    /usr/bin/nad_command $target_tty "Main.Power=Off" 2
                fi
                idlecount=$ttl
            else
                if [[ $state =~ "Main.Power=Off" ]]; then
                    echo "Amp ON"
                     /usr/bin/nad_command $target_tty "Main.Power=On" 2
                fi
            fi
        else
            echo "Source not set to Optical 1 but to $source. Not doing any checks."
        fi
    sleep 1
done
