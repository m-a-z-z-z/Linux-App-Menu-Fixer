# Linux-App-Menu-Fixer

## Who is this script for?
Users who run multiple desktop environments such as KDE and Gnome and do not want applications from each DE (Desktop Environment) serving the same purpose showing in their app menu.

## What this script will do
This script will hide all Gnome apps from KDE and all KDE apps from Gnome that the user selects by editing the desktop entry files in `/usr/share/applications` 
<br>
The script will simply add the line `OnlyShowIn=KDE;` and `OnlyShowIn=Gnome;` for KDE and Gnome apps respectively.
<br>

## Why make this script when I can simply hide applications in the app menu GUI?
While you can manually hide applications in the app menu for most DE's, this is a tedious process if you have multiple desktop environments installed, and you will have to do it for each DE. You could do what this script does manually in a text editor also, but updates to the applications may revert the changes you make causing you to have to these modifications again, which is why I made this script.
