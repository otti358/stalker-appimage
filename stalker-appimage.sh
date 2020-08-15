#!/usr/bin/env bash

# --------------------------------------------------------------
# VARIABLES
# --------------------------------------------------------------

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
script_file="$script_dir/$(basename "${BASH_SOURCE[0]}")"
script_res_dir="$script_dir/res"

stalker_dir="$HOME/.local/apps/stalker"
stalker_dir_sh="$HOME/.local/apps/stalker/stalker-appimage.sh"

wine="$stalker_dir/Wine-4.21-x86_64.AppImage"

# --------------------------------------------------------------
# FUNCTIONS
# --------------------------------------------------------------

print_header() {
    echo -e "

 _______   _______   _______            _     _   _______    ______  
 |______      |      |_____|   |        |____/    |______   |_____/  
 ______| .    |    . |     | . |_____ . |    \_ . |______ . |    \_ .

____ _  _ ____ ___  ____ _ _ _    ____ ____    ____ _  _ ____ ____ _  _ ____ ___  _   _ _    
[__  |__| |__| |  \ |  | | | |    |  | |___    |    |__| |___ |__/ |\ | |  | |__]  \_/  |    
___] |  | |  | |__/ |__| |_|_|    |__| |       |___ |  | |___ |  \ | \| |__| |__]   |   |___ 
                                                                                             

"
}

install() {

    install_exe_file="$1"

    if [ ! -f "$install_exe_file" ]; then
        echo "No Install exe file found: $install_exe_file"
        exit 1
    fi

    
    mkdir -p "$stalker_dir"

    # Download Win32-AppImage
    wget -O "$wine" https://github.com/sudo-give-me-coffee/wine32-deploy/releases/download/continuous/Wine-4.21-x86_64.AppImage
    chmod +x "$wine"

    # Create Wine Bottle
    "$wine" create-bottle stalker-bottle

    # Install File
    "$wine" install stalker-bottle "$install_exe_file"

    # Set Main Executable
    "$wine" set-main-executable stalker-bottle "C:/GOG Games/S.T.A.L.K.E.R. Shadow of Chernobyl/Settings.exe"

    # Copy Files
    cp "$script_res_dir/stalker-bottle.svg" "$HOME/.local/share/icons/"
    mv "$script_dir/stalker-bottle" "$stalker_dir"
    cp "$script_dir/stalker-appimage.sh" "$stalker_dir"

    # Create Desktop File
    {
        echo "[Desktop Entry]"
        echo "Name=Stalker"
        echo "Icon=stalker-bottle"
        echo "Exec=\"$stalker_dir_sh\" --run"
        echo "Type=Application"
    } >>"$HOME/.local/share/applications/stalker.desktop"
    
    # Notify
    notify-send -i "stalker-bottle" "Stalker successfully installed"
}

remove() {
    rm -r "$stalker_dir"
    rm "$HOME/.local/share/applications/stalker.desktop"
    rm "$HOME/.local/share/icons/stalker-bottle.svg"
    notify-send -i "wine" "Stalker successfully removed"
}



winetricks() {
    cd "$stalker_dir"
    "$wine" --winetricks stalker-bottle
}

run() {
    cd "$stalker_dir"
    "$wine" run stalker-bottle
}

# --------------------------------------------------------------
# MAIN
# --------------------------------------------------------------

print_header

if [ "$1" = "--install" ]; then
    install "$2"
    exit 0
fi

if [ "$1" = "--remove" ]; then
    remove
    exit 0
fi

if [ "$1" = "--winetricks" ]; then
    winetricks
    exit 0
fi

if [ "$1" = "--run" ]; then
    run
    exit 0
fi

if [ "$1" = "" ]; then
    echo -e "
    HELP:
    \t./stalker-appimage.sh --install /path/to/stalker/gog.exe
    \t./stalker-appimage.sh --run
    \t./stalker-appimage.sh --remove 
    \t./stalker-appimage.sh --winetricks
    "
    exit 0
fi