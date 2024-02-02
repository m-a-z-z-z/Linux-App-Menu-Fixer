#!/bin/bash

# TODO
# [x] Split program into two cases while testing
    # [x] Hide gnome apps case
    # [x] Hide KDE apps case 
# [] Merge cases once tested
# [x] Hide all org.gnome apps by default
# [x] Hide all org.kde apps by default
# [x] Suspected Gnome or KDE apps made optional / to be selected by user
# [x] Add programs to be hidden to a text file rather than an array.
    # This will allow querying by category which returns false positives that we can then blacklist from being hidden.
    # This will allow for more apps to be hidden besides the regular "org.gnome" or "org.kde" ones.
# [x] Trim whitespace in text file before modifying the .desktop files

# Variable declarations
logfile="logfile.txt"
gnome_apps_list="gnome_apps_list.txt"
kde_apps_list="kde_apps_list.txt"
apps_list="apps_list.txt"
modified_files="modifiedFilesList.txt"
> "$logfile"    # wipe previous log
> "$gnome_apps_list"
> "$kde_apps_list"
> "$apps_list"
directory="/home/maz/Desktop/usr.share.clone/applications"

echo "========================================================================================="
######################## Check if directory is valid ########################
if [ -d "$directory" ]; then
    echo "$directory found. Proceeding..." >> $logfile
else
    echo -e "\t\tError, Directory not found: $directory\nPlease open script and reconfigure to where your desktop entries are located." | tee -a $logfile
    exit 1
fi

######################## Prompt user to proceed ############################
echo -e "Script will hide KDE apps from GNOME and GNOME apps from KDE to fix the issue of mutliple apps serving the same purpose appearing in the app menu.\nDo you wish to proceed?"
read -p  "(yes/no): " answer

while [ "$answer" != "yes" ] && [ "$answer" != "y" ] && [ "$answer" != "no" ] && [ "$answer" != "n" ]; do
    echo "Invalid response, try again."
    read -p "(yes/no): " answer
done

if [ $answer = "yes" ] || [ $answer = "y" ]; then
    echo -e "\nProceeding..."
elif [ $answer = "no" ] || [ $answer = "n" ]; then
    echo "Operation cancelled. Exiting..."
    exit 0
fi

######################## Prompt user to select desktop apps to hide ########################
echo -e "\nDo you wish to hide GNOME or KDE apps from the opposing desktop?" 
read -p "(GNOME = g / KDE = k / All = a): " answer

while [ "$answer" != "g" ] && [ "$answer" != "k" ] && [ "$answer" != "a" ]; do
    echo "Invalid response, try again."
    read -p "(GNOME = g / KDE = k / All = a): " answer
done

######################## Find all applications which should be hidden ########################

# Add applications to be modified to text file
for app in "$directory"/*.desktop; do
    # Skip applications not displayed in app menu and 
    if grep -qiF "NoDisplay=true" "$app" || grep -qiF "NotShowIn=.*\bGNOME\b" "$app" || grep -qiF "NotShowIn=.*\bKDE\b" "$app"; then
        echo "$(basename "$app") Not displayed by default. No need to configure. Skipped." >> "$logfile"

    elif [ "$answer" = "g" ] && \
    { [[ "$(basename "$app")" == org.gnome* ]] || grep -qi "^Categories=.*\bGNOME\b" "$app"; }; then
        echo "$(basename "$app")" >> "$apps_list"

    elif [ "$answer" == "k" ] && \
    { [[ "$(basename "$app")" == org.kde* ]] || grep -qi "^Categories=.*\bKDE\b" "$app"; }; then
        echo "$(basename "$app")" >> "$apps_list"

    elif [ "$answer" = "a" ] && \
    { [[ "$(basename "$app")" == org.gnome* || "$(basename "$app")" == org.kde* ]] || \
    grep -qi "^Categories=.*\bGNOME\b" "$app" || grep -qi "^Categories=.*\bGNOME\b" "$app"; }; then
        echo "$(basename "$app")" >> "$apps_list"

    fi
done

######################## Blacklist applications from being modified ########################
echo -e "\nPress E to select apps to blacklist from modifications by commenting out with '#'.\nOtherwise press C to continue."
read -p "(Edit = E / Continue = C): " dummy_var
while [ "$dummy_var" != "E" ] && [ "$dummy_var" != "e" ] && [ "$dummy_var" != "C" ] && [ "$dummy_var" != "c" ]; do
    echo "Invalid response, try again."
    read -p "(Edit = E / Continue = C): " answer
done

if [ "$dummy_var" = "E" ] || [ "$dummy_var" = "e" ]; then
    vim "$apps_list"
    sed -i 's/^[[:space:]]*//' $apps_list
else
    echo "Continuing without blacklisting..." | tee -a $logfile
fi

echo -e "\n\tApps will now be hidden.\n\tPress Enter to continue or CTRL+C to cancel." && read
for ((i=3; i>0; i--)); do
    echo "$i..."
    sleep 1
done

######################## Modify the desktop entries ########################
while IFS= read -r line; do
    echo -e "\n$line"

    if grep "^#" <<< "$line"; then
        echo -e "\tPreserving current properties of $line. Skipped." | tee -a $logfile

    elif grep -qF "OnlyShowIn=" "$directory/$line"; then
        # Remove existing values to avoid any complications
        echo -e "\tDeleting current 'OnlyShowIn' values from $line." | tee -a $logfile
        sed -i '/OnlyShowIn=/d' "$directory/$line"

        if [[ "$line" == org.gnome* ]] || grep -qi "^Categories=.*\bGNOME\b" "$directory/$line"; then
            echo -e "\tAdding OnlyShowIn=GNOME to $line" | tee -a $logfile
            sed -i '/^\[Desktop Entry\]/a OnlyShowIn=GNOME;' "$directory/$line"

        elif [[ "$line" == org.kde* ]] || grep -qi "^Categories=.*\bKDE\b" "$directory/$line"; then
            echo -e "\tAdding OnlyShowIn=KDE to $line" | tee -a $logfile
            sed -i '/^\[Desktop Entry\]/a OnlyShowIn=KDE;' "$directory/$line"
        fi

    else
        if [[ "$line" == org.gnome* ]] || grep -qi "^Categories=.*\bGNOME\b" "$directory/$line"; then
            echo -e "\tAdding OnlyShowIn=GNOME to $line" | tee -a $logfile
            sed -i '/^\[Desktop Entry\]/a OnlyShowIn=GNOME;' "$directory/$line"

        elif [[ "$line" == org.kde* ]] || grep -qi "^Categories=.*\bKDE\b" "$directory/$line"; then
            echo -e "\tAdding OnlyShowIn=KDE to $line" | tee -a $logfile
            sed -i '/^\[Desktop Entry\]/a OnlyShowIn=KDE;' "$directory/$line"
        fi

    fi
done < "$apps_list"

echo -e "\n\t\tApplications hidden successfully. Exiting script..."


