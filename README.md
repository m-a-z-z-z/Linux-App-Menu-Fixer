# Linux-App-Menu-Fixer

## Who is this script for?
Users who run multiple desktop environments such as KDE and Gnome and do not want applications from each DE (Desktop Environment) serving the same purpose showing in their app menu.

## What this script will do
This script will hide all Gnome apps from KDE and all KDE apps from Gnome by editing the desktop entry files in `/usr/share/applications`.
<br>
Users can select apps to blacklist from being modified if there is a certain app from the DE they would like available in both.
<br>
The script will simply add the line `OnlyShowIn=KDE;` and `OnlyShowIn=Gnome;` for KDE and Gnome apps respectively.
<br>

## Why make this script when I can simply hide applications in the app menu GUI?
Basically just made this to skip that step if a reinstall is done, and if something like an update reverts any modifications made to the .desktop file.
