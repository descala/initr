#!/bin/sh

# Download free software

# firefox
DIR="Internet/firefox"
URL="http://download.mozilla.org/?product=firefox-3.0.10&os=win&lang=ca"
mkdir -p "$DIR" && cd "$DIR" && wget "$URL" 

# thunderbird
DIR="Thunderbird"
URL="http://download.mozilla.org/?product=thunderbird-2.0.0.21&os=win&lang=ca"
mkdir -p "$DIR" && cd "$DIR" && wget "$URL" 

# SP3 for office 2003 
# TODO: idiomas. this is spanish version
DIR="updates/office2003"
#URL="http://download.microsoft.com/download/7/7/8/778493c2-ace3-44c5-8bc3-d102da80e0f6/Office2003SP3-KB923618-FullFile-ENU.exe"
URL="http://download.microsoft.com/download/b/3/b/b3bd1060-0b3c-442e-a38c-fc81ba9fde9f/Office2003SP3-KB923618-FullFile-ESN.exe"

# openoffice 3
# TODO: idiomas. this is spanish version
DIR="OpenOffice.org/OOo_301_es"
URL="http://openoffice.bouncer.osuosl.org/?product=OpenOffice.org&os=win&lang=es&version=3.0.1"
mkdir -p "$DIR" && cd "$DIR" && wget "$URL" 
# TODO: cal un pas manual
# que descomprimeix arxius, executant el OOo_3.0.1_Win32Intel_install_es.exe des de windows

wget "http://download.microsoft.com/download/9/4/2/942080a4-ba69-496b-a379-d3b26d37b647/WindowsXP-KB936929-SP3-x86-ESN.exe"