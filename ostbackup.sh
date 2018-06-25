#!/bin/bash

#
# Bash script for creating backups of OSticket.
# Usage: ./ostbackup.sh 
# 
#Based upon https://github.com/DecaTec/Nextcloud-Backup-Restore

#
# IMPORTANT
# You have to customize this script (directories, users, etc.) for your actual environment.
# All entries which need to be customized are tagged with "TODO".
#
# OPTIONALLY
# You can set this script to perform backups only during office hours 
# (f.i. when executing backup every hour, to prevent backups when nothing really changes to your data)
# To do so edit section "WORKING HOURS"
#

# Variables
currentDate=$(date +"%Y%m%d_%H%M%S")
# TODO: The directory where you store the OSticket backups
backupMainDir="/mnt/share/OSticketBackups"
# The actual directory of the current backup - this is is subdirectory of the main directory above with a timestamp
backupdir="${backupMainDir}/${currentDate}/"
# TODO: The directory of your OSticket installation (this is a directory under your web root)
osticketFileDir="/var/www/osticket"
# TODO: If you have a separate attachment directory uncomment this line as well as the actual section to restore this directory below
#osticketDataDir="/var/OSattachments" 
# TODO: Your OSticket database name
osticketDatabase="osticketdb"
# TODO: Your OSticket database user
dbUser="osticket"
# TODO: The password of the OSticket database user
dbPassword="PaSSw0rd"
# TODO: Your web server user
webserverUser="www-data"
# TODO: The maximum number of backups to keep (when set to 0, all backups are kept)
maxNrOfBackups=30

# File names for backup files
# If you prefer other file names, you'll also have to change the OSticket.sh script.
fileNameBackupFileDir="OSticket-filedir.tar.gz"
fileNameBackupDataDir="OSticket-datadir.tar.gz"
fileNameBackupDb="OSticket-db.sql"

# Function for error messages
errorecho() { cat <<< "$@" 1>&2; }

# WORKING HOURS
# To perform a backup only during working hours uncomment & edit this section
#H=$(date +%H)
#only backup between 8:00 & 17:00
#if (( 8 <= 10#$H && 10#$H < 17 )); then
#    echo ok its working hours 
#else
#echo no backup is made
#exit 0
#fi

#
# Check for root
#
if [ "$(id -u)" != "0" ]
then
	errorecho "ERROR: This script has to be run as root!"
	exit 1
fi

#
# Check if backup dir already exists
#
if [ ! -d "${backupdir}" ]
then
	mkdir -p "${backupdir}"
else
	errorecho "ERROR: The backup directory ${backupdir} already exists!"
	exit 1
fi

#
# Backup file directory
#
echo "Creating backup of OSticket file directory..."
tar -cpzf "${backupdir}/${fileNameBackupFileDir}" -C "${osticketFileDir}" .
echo "Done"
echo

#
# Uncomment this section if you have a separate directory for attachments
#
#echo "Creating backup of OSticket data directory..."
#tar -cpzf "${backupdir}/${fileNameBackupDataDir}"  -C "${osticketDataDir}" .
#echo "Done"
#echo

#
# Backup DB
#
echo "Backup OSticket database..."
mysqldump --single-transaction -h localhost -u "${dbUser}" -p"${dbPassword}" "${osticketDatabase}" > "${backupdir}/${fileNameBackupDb}"
echo "Done"
echo


#
# Delete old backups
#
if (( ${maxNrOfBackups} != 0 ))
then	
	nrOfBackups=$(ls -l ${backupMainDir} | grep -c ^d)
	
	if (( ${nrOfBackups} > ${maxNrOfBackups} ))
	then
		echo "Removing old backups..."
		ls -t ${backupMainDir} | tail -$(( nrOfBackups - maxNrOfBackups )) | while read dirToRemove; do
		echo "${dirToRemove}"
		rm -r ${backupMainDir}/${dirToRemove}
		echo "Done"
		echo
    done
	fi
fi

echo
echo "DONE!"
echo "Backup created: ${backupdir}"


