#!/bin/bash
config="$1"
rom="$2"
rom_bn="${rom%.*}"

pushd "${0%/*}" >/dev/null
if [[ "$rom" == *.uae ]]; then
    /opt/retropie/emulators/retroarch/bin/retroarch -v -L /opt/retropie/libretrocores/puae-libretro/puae_libretro.so --config /opt/retropie/configs/amiga/retroarch.cfg "$rom"
else
    source "../../lib/archivefuncs.sh"

    archiveExtract "$rom" ".adf .adz .dms"

    # check successful extraction and if we have at least one file
    if [[ $? == 0 ]]; then
        for i in {0..3}; do
            [[ -n "${arch_files[$i]}" ]] && images+=("${arch_files[$i]}")
        done
        name="${arch_files[0]}"
    elif [[ -n "$rom" ]]; then
        name="$rom"
        # try and find the disk series
        base="${name##*/}"
        base="${base%Disk*}"
        while read -r disk; do
            images+=("$disk")
            [[ "$i" -eq 4 ]] && break
        done < <(find "${rom%/*}" -iname "$base*" | sort)
        [[ "${#images[@]}" -eq 0 ]] && images=("$rom")
    fi
 
    conf="$(mktemp)"
    cat $config >> $conf
    for i in "${!images[@]}"; do 
        echo "floppy${i}=${images[$i]}" >> $conf
        echo "floppy${i}type=0" >> $conf
    done
    echo "nr_floppies=${#images[@]}" >> $conf

    /opt/retropie/emulators/retroarch/bin/retroarch -v -L /opt/retropie/libretrocores/puae-libretro/puae_libretro.so --config /opt/retropie/configs/amiga/retroarch.cfg $conf
    rm $conf
    archiveCleanup
fi

popd
