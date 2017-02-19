#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="puae-libretro"
rp_module_desc="P-UAE Amiga emulator port for libretro"
rp_module_help="ROM Extensions: .zip\n\nCopy your roms to $romdir/amiga, for multidisk create a single archive with _Disk*.adf as filenames"
rp_module_section="exp"

function sources_puae-libretro() {
    gitPullOrClone "$md_build" https://github.com/libretro/libretro-uae.git
}

function build_puae-libretro() {
    make
    #temp remove later
    #cp $md_data/puae_libretro.so $md_build -v
    md_ret_require="$md_build/puae_libretro.so"
}

function install_puae-libretro() {
    md_ret_files=(
        'puae_libretro.so'
        'README'
    )
}

function configure_puae-libretro() {
    mkRomDir "amiga"
    mkUserDir "$md_conf_root/amiga"
    mkUserDir "$md_conf_root/amiga/$md_id"

    ensureSystemretroconfig "amiga"
    
    local conf="$(mktemp)"
    cat "$md_data/template.uae" >> $conf
    echo "kickstart_rom_file=${biosdir}/kick13.rom" >> $conf

    copyDefaultConfig "$conf" "$md_conf_root/amiga/$md_id/template.uae"
    rm "$conf"

    cp -v "$md_data/puae.sh" "$md_inst/"

    addEmulator 1 "$md_id" "amiga" "bash $md_inst/puae.sh $md_conf_root/amiga/$md_id/template.uae %ROM%"
    addSystem "amiga"
}
