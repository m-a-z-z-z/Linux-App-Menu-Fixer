#!/bin/bash

# TODO
# [x] Split program into two cases while testing
    # [x] Hide gnome apps case
    # [x] Hide KDE apps case 
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
modified_files="modifiedFilesList.txt"
> "$logfile"    # wipe previous log
> "$gnome_apps_list"
> "$kde_apps_list"
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
    echo "Proceeding..."
elif [ $answer = "no" ] || [ $answer = "n" ]; then
    echo "Operation cancelled. Exiting..."
    exit 0
fi

######################## Prompt user to select desktop apps to hide ########################
echo "\nDo you wish to hide GNOME or KDE apps from the opposing desktop?" 
read -p "(GNOME = g / KDE = k): " answer

while [ "$answer" != "g" ] && [ "$answer" != "k" ]; do
    echo "Invalid response, try again."
    read -p "(GNOME = g / KDE = k): " answer
done

######################## Find GNOME apps and add them to list for sorting later ########################
if [ $answer = "g" ]; then
    echo -e "\n\t\tFinding all GNOME applications..."
    for app in "$directory"/*.desktop; do
        if grep -qiF "NoDisplay=true" $app || grep -qiF "NotShowIn=*\bGNOME\b" $app; then     # Check if app contains NoDisplay=true so it can be skipped.
            echo "$(basename "$app") Not displayed by default. No need to configure. Skipped." >> $logfile

        elif [[ "$(basename "$app")" == org.gnome* ]]; then     # Add all org.gnome entries to list as they are likely preinstalled with Gnome
            echo "$(basename "$app")" >> $gnome_apps_list

        elif grep -qi "^Categories=.*\bGNOME\b" "$app"; then
            # Most precise I was able to get this regex, these programs that are added will be commented out. 
            # If users wish to hide them, they can uncomment them when the script opens the list in VIM.
            echo "#$(basename "$app")" >> $gnome_apps_list

        else
            echo "$(basename "$app") not preinstalled GNOME or KDE app. Skipped." >> $logfile    # Triggers for apps user installed/non system apps

        fi
    done

    if [ -e "$gnome_apps_list" ]; then
        
        echo -e "\n\tUncomment applications you want hidden by removing '#' at the start of the line."
        vim "$gnome_apps_list"
        sed -i 's/^[[:space:]]*//' $gnome_apps_list
        echo -e "\n\tApps will now be hidden.\n\tPress Enter to continue or CTRL+C to cancel." && read
        for ((i=3; i>0; i--)); do
            echo "$i..."
            sleep 1
        done

        while IFS= read -r line; do
            echo -e "\n$line"

            if grep "^#" <<< "$line"; then  # Check if application is commented out from list and skip if it is
                echo -e "\tPreserving current properties of $line. Skipped." | tee -a $logfile

            elif grep -qF "OnlyShowIn=" "$directory/$line"; then
                echo -e "\tDeleting current 'OnlyShowIn' values from $line." | tee -a $logfile
                sed -i '/OnlyShowIn=/d' "$directory/$line" # Delete any current values to avoid complications
                
                echo -e "\tAppending OnlyShowIn=GNOME to $line" | tee -a $logfile
                sed -i '/^\[Desktop Entry\]/a OnlyShowIn=GNOME;' "$directory/$line"

            else
                echo -e "\tAppending OnlyShowIn=GNOME to $line" | tee -a $logfile
                sed -i '/^\[Desktop Entry\]/a OnlyShowIn=GNOME;' "$directory/$line"

            fi
        done < "$gnome_apps_list"
    else
        echo "Oopsy woopsy, I done messed up somewhere son."
        exit 1
    fi

######################## Find KDE apps and add them to list for sorting later ########################
elif [ $answer = "k" ]; then
    echo -e "\n\t\tFinding all  KDE applications..."
    for app in "$directory"/*.desktop; do
        if grep -qiF "NoDisplay=true" $app || grep -qiF "NotShowIn=*\bKDE\b" $app; then     # Check if app contains NoDisplay=true so it can be skipped.
            echo "$(basename "$app") Not displayed by default. No need to configure. Skipped." >> $logfile

        elif [[ "$(basename "$app")" == org.kde* ]]; then     # Add all org.gnome entries to list as they are likely preinstalled with Gnome
            echo "$(basename "$app")" >> $kde_apps_list

        elif grep -qi "^Categories=.*\bKDE\b" "$app"; then
            # Most precise I was able to get this regex, these programs that are added will be commented out. 
            # If users wish to hide them, they can uncomment them when the script opens the list in VIM.
            echo "#$(basename "$app")" >> $kde_apps_list

        else
            echo "$(basename "$app") not preinstalled GNOME or KDE app. Skipped." >> $logfile    # Triggers for apps user installed/non system apps

        fi
    done

    if [ -e "$kde_apps_list" ]; then
        
        echo -e "\n\tUncomment applications you want hidden by removing '#' at the start of the line."
        vim "$kde_apps_list"
        sed -i 's/^[[:space:]]*//' $kde_apps_list
        echo -e "\n\tApps will now be hidden.\n\tPress Enter to continue or CTRL+C to cancel." && read
        for ((i=5; i>0; i--)); do
            echo "$i..."
            sleep 1
        done

        while IFS= read -r line; do
            echo -e "\n$line"

            if grep "^#" <<< "$line"; then  # Check if application is commented out from list and skip if it is
                echo -e "\tPreserving current properties of $line. Skipped." | tee -a $logfile

            elif grep -qF "OnlyShowIn=" "$directory/$line"; then
                echo -e "\tDeleting current 'OnlyShowIn' values from $line." | tee -a $logfile
                sed -i '/OnlyShowIn=/d' "$directory/$line" # Delete any current values to avoid complications
                
                echo -e "\tAppending OnlyShowIn=KDE to $line" | tee -a $logfile
                sed -i '/^\[Desktop Entry\]/a OnlyShowIn=KDE;' "$directory/$line"

            else
                echo -e "\tAppending OnlyShowIn=KDE to $line" | tee -a $logfile
                sed -i '/^\[Desktop Entry\]/a OnlyShowIn=KDE;' "$directory/$line"

            fi
        done < "$kde_apps_list"
    else
        echo "Oopsy woopsy, I done messed up somewhere son."
        exit 1
    fi
fi

echo -e "\n\t\tApplications hidden successfully. Exiting script..."


