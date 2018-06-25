#!/bin/bash

#
# Bash script for restoring backups of OSticket.
# Usage: ./ostrestore.sh <BackupName> (e.g. ./ostrestore.sh 20170910_132703)
# 
# Based upon https://github.com/DecaTec/Nextcloud-Backup-Restore

#
# IMPORTANT
# You have to customize this script (directories, users, etc.) for your actual environment.
# All entries which need to be customized are tagged with "TODO".
#

# Variables
# TODO: The directory where you store the OSticket backups
mainBackupDir="/mnt/share/OSticketBackups/"
restore=$1
currentRestoreDir="${mainBackupDir}/${restore}"
# TODO: The directory of your OSticket installation (this is a directory under your web root)
osticketFileDir="/var/www/osticket"
# TODO: If you have a separate attachment directory uncomment this line as well as the section to restore this directory below
#osticketDataDir="/var/OSattachments"
# TODO: The service name of the web server. Used to start/stop web server (e.g. 'service <webserverServiceName> start')
webserverServiceName="apache2"
# TODO: Your OSticket database name
osticketDatabase="osticketdb"
# TODO: Your OSticket database user
dbUser="osticket"
# TODO: The password of the OSticket database user
dbPassword="PaSSw0rd"
# TODO: Your web server user
webserverUser="www-data"

# File names for backup files
# If you prefer other file names, you'll also have to change the ostbackup.sh script.
fileNameBackupFileDir="OSticket-filedir.tar.gz"
fileNameBackupDataDir="OSticket-datadir.tar.gz"
fileNameBackupDb="OSticket-db.sql"

# Function for error messages
errorecho() { cat <<< "$@" 1>&2; }

#
# Check if parameter given
#
if [ $# != "1" ]
then
    errorecho "ERROR: No backup name to restore given!"
	errorecho "Usage: ./ostrestore.sh 'BackupDate'"
    exit 1
fi

#
# Check for root
#
if [ "$(id -u)" != "0" ]
then
    errorecho "ERROR: This script has to be run as root!"
    exit 1
fi

#
# Check if backup dir exists
#
if [ ! -d "${currentRestoreDir}" ]
then
	 errorecho "ERROR: Backup ${restore} not found!"
    exit 1
fi

#
# Stop web server
#
echo "Stopping web server..."
service "${webserverServiceName}" stop
echo "Done"
echo

#
# Delete old OSticket direcories
#
echo "Deleting old OSticket file directory..."
rm -r "${osticketFileDir}"
mkdir -p "${osticketFileDir}"
echo "Done"
echo

#
#uncomment this section if you have separate attachement directory
#

echo "Deleting old OSticket data directory..."
rm -r "${osticketDataDir}"
mkdir -p "${osticketDataDir}"
echo "Done"
echo

#
# Restore file and data directory
#
echo "Restoring OSticket file directory..."
tar -xpzf "${currentRestoreDir}/${fileNameBackupFileDir}" -C "${osticketFileDir}"
echo "Done"
echo

#
#uncomment this section if you have separate attachement directory
#
echo "Restoring OSticket data directory..."
tar -xpzf "${currentRestoreDir}/${fileNameBackupDataDir}" -C "${osticketDataDir}"
echo "Done"
echo

#
# Restore database
#
echo "Dropping old OSticket DB..."
mysql -h localhost -u "${dbUser}" -p"${dbPassword}" -e "DROP DATABASE ${osticketDatabase}"
echo "Done"
echo

echo "Creating new DB for osticket..."
mysql -h localhost -u "${dbUser}" -p"${dbPassword}" -e "CREATE DATABASE ${osticketDatabase}"
echo "Done"
echo

echo "Restoring backup DB..."
mysql -h localhost -u "${dbUser}" -p"${dbPassword}" "${osticketDatabase}" < "${currentRestoreDir}/${fileNameBackupDb}"
echo "Done"
echo

#
# Start web server
#
echo "Starting web server..."
service "${webserverServiceName}" start
echo "Done"
echo

#
# Set directory permissions
#
echo "Setting directory permissions..."
chown -R "${webserverUser}":"${webserverUser}" "${osticketFileDir}"
chown -R "${webserverUser}":"${webserverUser}" "${osticketDataDir}"
echo "Done"
echo


echo
echo "DONE!"
echo "Backup ${restore} successfully restored."
