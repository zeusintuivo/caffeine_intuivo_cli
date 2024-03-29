#!/bin/bash
#               __  __      _
#     ___ __ _ / _|/ _| ___(_)_ __   ___
#    / __/ _` | |_| |_ / _ \ | '_ \ / _ \
#   | (_| (_| |  _|  _|  __/ | | | |  __/
#    \___\__,_|_| |_|  \___|_|_| |_|\___|
#
# --- Linux desktop environment for geeks ---
#
#
# Copyright (c) 2018 imm studios, z.s.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
##############################################################################
## COMMON UTILS

base_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
config_dir=$HOME/.config
temp_dir="/tmp/caffeine-installer"

function error_exit {
    printf "\n\033[0;31mInstallation failed\033[0m\n"
    cd ${base_dir}
    exit 1
}

function finished {
    printf "\n\033[0;92mInstallation completed\033[0m\n"
    cd ${base_dir}
    exit 0
}

if [ ! -d ${temp_dir} ]; then
    mkdir ${temp_dir} || error_exit
fi

if [ ! -d $config_dir ]; then
    mkdir $config_dir;
fi

## COMMON UTILS
##############################################################################


function download_repo() {
    cd ${temp_dir}
    repo=$1
    repo_name=$(basename $repo)
    if [ -d $repo_name ]; then
        cd $repo_name
        git pull || return 1
        cd ..
    else
        git clone $repo || return 1
    fi
    return 0
}


function install_dnf {
    dnf update || return 1

    # X server and audio
    # call was:
    #    dnf install -vy \
    #        xserver-xorg xdm  \
    #        pulseaudio pulseaudio-utils pavucontrol
    # problems:
    # problem with installed package pipewire-pulseaudio
    # No match for argument: xserver-xorg
    # problem with installed package i3-gaps
    # adjustments:
    dnf install  xdm  pavucontrol -vy || return 1

    # Desktop notifications
    # call was:
    #    dnf install -vy dunst libnotify-bin dbus-x11 || return 1
    # problems:
    #     No match for argument: libnotify-bin
    # adjustments:
    dnf install -y dunst dbus-x11 || return 1

    # Console utils
    # call was:
    #    dnf install -vy vim git screen curl mc rsync aptitude source-highlight
    # problem:
    #    No match for argument: aptitude
    # adjustment:
    dnf install -y vim git screen curl mc rsync source-highlight || return 1
    # calls was:
    #   dnf install -vy htop nload nmap net-tools build-essential autoconf
    # problem:
    #   No match for argument: build-essential
    # adjustment:
    dnf install -y htop nload nmap net-tools autoconf || return 1
    # calls was and is:
    dnf install -y automake autogen figlet cowsay w3m mediainfo unoconv odt2txt catdoc python-pip python3-pip || return 1
    # No problems:

    # GUI utils
    # call was:
    #   dnf install -vy numlockx xclip rxvt-unicode-256color arandr acpi rofi compton redshift xbacklight mpd mpc ncmpcpp \
    # problems:
    #   No match for argument: rxvt-unicode-256color vim-gtk
    # adjustments:
    #    dnf install -vy numlockx xclip arandr acpi rofi compton redshift xbacklight mpd mpc ncmpcpp
    # problem: discontinued compton
    # adjustments:
    dnf install -y numlockx xclip arandr acpi rofi picom redshift xbacklight mpd mpc ncmpcpp \
		  	zathura mpv feh scrot vlc vim || return 1

    # GTK utils
    # call was:
		# dnf install -y \
    #    gtk2-engines-pixbuf gtk2-engines-murrine || return 1
    # problems:
		#    Error: Unable to find a match: gtk2-engines-pixbuf gtk2-engines-murrine
		#
    dnf install -y gdk-pixbuf2 rust-gdk-pixbuf-sys-devel rust-gdk-pixbuf-devel gdk-pixbuf2-devel gdk-pixbuf2-modules gdk-pixbuf2-xlib gtk-murrine-engine 

    pip3 install py3status python-mpd2 || return 1


    #
    # ETC
    #


    cp $caffeine_dir/global/etc/X11/xdm/Xresources /etc/X11/xdm/Xresources
    cp $caffeine_dir/global/etc/X11/xdm/Xsetup /etc/X11/xdm/Xsetup

    #
    # USR
    #

    # Default background
    if [ ! -d /usr/share/backgrounds ]; then
        mkdir -p /usr/share/backgrounds
    fi
    cp $base_dir/global/usr/share/backgrounds/caffeine.png /usr/share/backgrounds

    # Console font
    if [ ! -d /usr/share/fonts/caffeine-font ]; then
        mkdir -p /usr/share/fonts/caffeine-font
    fi
    cp -r $base_dir/global/usr/share/fonts/caffeine-font /usr/share/fonts/

    # Set urxvt as default terminal
    update-alternatives --set x-terminal-emulator /usr/bin/urxvt

    # Disable system-wide MPD
    if [ -f /etc/mpd.conf ]; then rm /etc/mpd.conf; fi
    systemctl disable mpd

    # urxvt plugins
    if [ ! -d /usr/lib/urxv/perl ]; then
        mkdir -p /usr/lib/urxvt/perl
    fi
    cp global/usr/lib/urxvt/perl/* /usr/lib/urxvt/perl

}



function install_i3 {
    command -v i3 >/dev/null 2>&1 && return 0

    # dnf install -y \
        # libxcb1-dev libxcb-keysyms1-dev  
				#		libpango1.0-dev 
				#		libxcb-util0-dev \
        # libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev \
        # libxcb-randr0-dev libev-dev 
				#				libxcb-cursor-dev 
			 #					libxcb-xinerama0-dev \
       # libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev \
      #  libxcb-xrm0 libxcb-xrm-dev libxcb-shape0-dev || return 1
 
		dnf install -y \
			  libxcb-devel xcb-util-keysyms xcb-util xcb-util-devel xcb-util-keysyms-devel \
		xcb-util-cursor xcb-util-cursor-devel rust-xcb+xinerama-devel \
   rust-xcb+xkb-devel xcb-util-xrm-devel xcb-util-xrm libxkbcommon \
	 libxkbcommon-devel rust-xkbcommon+default-devel rust-xkbcommon-devel \
	 rust-xkbcommon+wayland-devel libxkbcommon-x11-devel libxkbcommon-x11  \
    rust-xcb+shape-devel rust-xcb+randr-devel libev-devel rust-xcb+genericevent-devel \
		pango pango-devel rust-pango-devel yajl yajl-devel startup-notification \ 
	 	startup-notification-devel arandr xrandr rust-xcb+randr-devel libXrandr-devel \ 
		autorandr lxrandr rust-x11+xrandr-devel libXrandr xbacklight 

    download_repo "https://github.com/Airblader/i3"

    cd ${temp_dir}/i3
    if [ -d build/ ]; then
        rm -rf build/
    fi
    mkdir build/
    autoreconf --force --install || return 1
    cd build
    ../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers || return 1
    make || return 1
    make install || return 1

    dnf install -y i3lock i3status || return 1
}


function install_user {
    if [ -f $HOME/.Xresources ];        then rm $HOME/.Xresources; fi
    if [ -d $config_dir/i3 ];           then rm -rf $config_dir/i3; fi
    if [ -d $config_dir/i3status ];     then rm -rf $config_dir/i3status; fi
    if [ -d $config_dir/mpd ];          then rm -rf $config_dir/mpd; fi
    if [ -d $config_dir/mpv ];          then rm -rf $config_dir/mpv; fi
    if [ -d $config_dir/scripts ];      then rm -rf $config_dir/scripts; fi

    [[ ! -e "$HOME/.Xresources" ]] && ln -s $base_dir/home/.Xresources          $HOME/.Xresources
    [[ ! -e "$config_dir/i3" ]] && ln -s $base_dir/home/.config/i3           $config_dir/i3
    [[ ! -e "$config_dir/i3status" ]] && ln -s $base_dir/home/.config/i3status     $config_dir/i3status
    [[ ! -e "$config_dir/mpd" ]] && ln -s $base_dir/home/.config/mpd          $config_dir/mpd
    [[ ! -e "$config_dir/mpv" ]] && ln -s $base_dir/home/.config/mpv          $config_dir/mpv
    [[ ! -e "$config_dir/scripts" ]] && ln -s $base_dir/home/.config/scripts      $config_dir/scripts
    [[ ! -e "$config_dir/dunst" ]] && ln -s $base_dir/home/.config/dunst        $config_dir/dunst

    echo "exec i3 > $HOME/.xsession"

    xdg-mime default feh.desktop image/jpeg
    xdg-mime default feh.desktop image/png

}




if [ "$(id -u)" != "0" ]; then
    install_user || error_exit
else
    install_dnf || error_exit
    install_i3 || error_exit
fi





