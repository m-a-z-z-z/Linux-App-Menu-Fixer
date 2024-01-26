#!/bin/bash

# Variable declarations
log_file="/home/maz/Desktop/HideDElogs/logfile.txt"
directory="/home/maz/Desktop/Test_desktop_files/"
gnome_app_array=()
kde_app_array=()

echo "========================================================================================="
echo -e "Script will hide KDE apps from Gnome and Gnome apps from KDE to fix the issue of mutliple apps serving the same purpose appearing in the app menu. \n Do you wish to proceed? (yes/no)"
read answer

exec >> "$log_file" 2>&1

case "$answer" in 
    "yes")
        # Check if directory exists
        if [ -d "$directory" ]; then
        
            # Find Gnome apps and add them to array for sorting through
            echo -e "\n\tSelect applications to hide:"
            for gnome_app in "$directory"/Gnome_apps/*org.gnome*; do
                if [ -e "$gnome_app" ]; then
                    # echo -e "\t\t$gnome_app"
                    gnome_app_array+=("$gnome_app")
                else
                    echo -e "\t\tNo org.gnome .desktop files found in $directory"
                fi
            done

            # Sort through apps that need to be edited and apps that can be left alone.
            echo "Contents of gnome array"
            for gnome_app in "${gnome_app_array[@]}"; do
                if grep -qF "NoDisplay=" "$directory"/Gnome_apps/"$gnome_app"; then
                    echo "$gnome_app is not a menu item application. Already hidden."
                elif grep -qF "OnlyShowIn=" "$directory"/Gnome_apps/"$gnome_app"; then
                    sed -i '/OnlyShowIn=/d' "$directory"/Gnome_apps/"$gnome_app" # Delete any current values to avoid complications
                    echo "Deleting current OnlyShowIn value from $gnome_app"
                    sed -i '/^\[Desktop Entry\]/a OnlyShowIn=Gnome;' "$directory"/Gnome_apps/"$gnome_app"
                elif grep -qF "NotShowIn=" "$directory"/Gnome_apps/"$gnome_app"; then
                    sed -i '/NotShowIn=/d' "$directory"/Gnome_apps/"$gnome_app" # Delete any current values to avoid complications
                    echo "Deleting current NotShowIn value from $gnome_app"
                    sed -i '/^\[Desktop Entry\]/a OnlyShowIn=Gnome;' "$directory"/Gnome_apps/"$gnome_app"
                else
                    sed -i '/^\[Desktop Entry\]/a OnlyShowIn=Gnome;' "$directory"/Gnome_apps/"$gnome_app"
                    echo "Appending OnlyShowIn=Gnome; to $gnome_app"
                fi
            done

        else
            echo -e "\tError, Directory not found: $directory"
            exit 1
        fi

        echo -e "\n\n\t\tApplications hidden successfully. Script will now close."        
        
        # Countdown loop
        for ((i=3; i>0; i--)); do
            echo "$i..."
            sleep 1
        done
        exec >> /dev/tty 2>&1
        echo "========================================================================================="
        exit 0
        ;;
    "no")
        echo -e "\nOperation cancelled. Exiting..."
        exec >> /dev/tty 2>&1
        echo "========================================================================================="
        exit 0
        ;;
    *)
        echo -e "\nInvalid choice. Please enter 'yes' or 'no'."
        exec >> /dev/tty 2>&1
        echo "========================================================================================="
        ;;
esac


