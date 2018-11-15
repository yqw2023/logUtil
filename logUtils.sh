#!/bin/bash
# --------------------------------------------------------------------------------
# logUtils for backup & clean
# (c) QingWen Ye 2018
#
# A simple log backup and clean script in BASH.
#
# Some configuration options are supported. Read about them in the README.md file
# --------------------------------------------------------------------------------

# log conf info ------------------------------------------
if [ -e /etc/logUtils.config ]; then
    . /etc/logUtils.config
fi

if [ -z "$LOG_DIR" ]; then
    echo '$LOG_DIR not set in configuration.' 1>&2
    exit 1
fi

if [ -z "$BACKUP_DIR" ]; then
    echo 'Backup directory not set in configuration.' 1>&2
    exit 3
fi

if [ -z "$MAX_BACKUPS" ]; then
    echo 'Max backups not configured.' 1>&2
    exit 4
fi

# First command line arg indicates dry mode meaning don't actually run clean & backup
DRY_MODE=0
if [ -n "$1" -a "$1" == 'dry' ]; then
    DRY_MODE=1
fi

# Check for external dependencies, bail with an error message if any are missing
for program in date $BKUP_BIN head hostname ls rm tr wc
do
    which $program 1>/dev/null 2>/dev/null
    if [ $? -gt 0 ]; then
        echo "External dependency $program not found or not in $PATH" 1>&2
        exit 6
    fi
done

# the date is used for backup file names
date=$(date +%F)
yestoday=$(date -d "1 day ago" +%Y-%m-%d)

echo "== Running $0 on $(hostname) - $date =="; echo

    # each db gets its own directory
    if [ ! -d "$backupDir" ]; then
        # create the backup dir for $db if it doesn't exist
        echo "Creating directory $backupDir"
        mkdir -p "$backupDir"
    else
        # nuke any backups beyond $MAX_BACKUPS
        numBackups=$(ls -1lt "$backupDir"/*."$BKUP_EXT" 2>/dev/null | wc -l) # count the number of existing backups for $db
        if [ -z "$numBackups" ]; then numBackups=0; fi

        if [ "$numBackups" -ge "$MAX_BACKUPS" ]; then
            # how many files to nuke
            ((numFilesToNuke = "$numBackups - $MAX_BACKUPS + 1"))
            # actual files to nuke
            filesToNuke=$(ls -1rt "$backupDir"/*."$BKUP_EXT" | head -n "$numFilesToNuke" | tr '\n' ' ')

            echo "Nuking files $filesToNuke"
            echo "rm $filesToNuke"
#            rm $filesToNuke
        fi
    fi




while [ $# \> 0 ]
  do
    directory=$1
    for file in $(find "$directory" -name "*.$yestoday.log")
    do
      echo "gzip file $file">>${record_file}
    done
    shift
  done
