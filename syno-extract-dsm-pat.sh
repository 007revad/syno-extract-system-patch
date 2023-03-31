#!/usr/bin/env bash
#-----------------------------------------------------------
# Extract Synology DSM 7 .pat files that are not .tgz files
#
#   https://github.com/007revad/syno-extract-system-patch
#-----------------------------------------------------------

if [[ $( whoami ) == "root" ]]; then
    echo "This script should NOT be run by root."
    echo "Saving files to /root can cause DSM updates to fail."
    exit 1
fi

# Remove any @eaDir directories
find ~/data/ -type d -name "@eaDir" -exec rm -r {} \; >/dev/null


if [[ -n $1 ]]; then
    patfile=$1
else
    # Select pat from ~/data/in
    PS3='Please select a pat file: '
    readarray -t options < <(ls ~/data/in | grep \.pat)

    select opt in "${options[@]}"; do
    IFS=' ' read name ip <<< $opt
    case $opt in  
        $opt)
            echo "You selected $opt"
            patfile=$opt
            break
            ;; 
        *) 
            echo "Invalid selection!"
            ;;
        esac
    done
fi

if [[ ! -f ~/data/in/$patfile ]]; then
    echo -e "$patfile not found!\n"
    exit 1
fi


#name="$(basename -- "$patfile")"
name="${patfile%.*}"

if [[ ! -d ~/data/out/"$name" ]]; then
    if [[ -d ~/data/out ]]; then
        error="Failed to create directory:"
        mkdir ~/data/out/"$name" || \
            { echo -e "${error}\n  ~/data/out/$name"; exit 1; }
    else
        echo -e "Missing directory:\n ~/data/out/$name"
        exit 1
    fi
fi

if [[ -n $(ls -A ~/data/out/"$name") ]]; then
    echo ~/"data/out/$name is not empty!"
    exit 1
fi


sudo docker run --rm -v ~/data:/data syno-extract-system-patch \
  /data/in/"$patfile" \
  /data/out/"$name"/.

exit 0

