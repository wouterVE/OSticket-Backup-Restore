# OSticket-Backup-Restore
Bash scripts to create backups en execute restore for OSticket. 

Based upon https://github.com/DecaTec/Nextcloud-Backup-Restore

# Usage
Before you can use these scripts, you will need to adjust is to reflect your actual installation. 
All lines which need to be edited are preceded by TODO.

To perform a backup of OSticket, at least 2 items need to be backed up:
- The file directory (usually under /www/)
- The SQL database
- Optionally: if you use a plugin to have a separate attachments directory you need to backup this as well

# Backup
Before you can create a backup, you first need to make the file *ostbackup.sh* executable with `chmod +X ostbackup.sh`. 
Then call the script with `./ostbackup.sh`as `root`or with `sudo`. If you fail to do so, an error will return that the script does not have root privileges. 
  
 ## Automatic backups with cronjob
 Preferably, you call this script periodically with a cronjob. Edit your crontab with `crontab -e` as `root` and add something like this:
 `0 1 * * * /path/to/the/scripts/folder/./ostbackup.sh`
 This will create a backup every day at 1 am. You can adjust this accordingly to your preferences.
 
 # Restore
 To restore a backup, use this command:
 `./ostrestore.sh /path/to/ostbackups/<BackupName>`
 With `<BackupName>` the name of the directory where the backup is stored (in format YYYYMMDD_HHMMSS e.g. 20170910_132703). This will shutdown the webserver (e.g. apache), delete the file directory, sql database and optionally the attachments folder and restore them from the backup. 
