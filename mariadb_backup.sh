#!/bin/bash

### APAGAR BACKUP ANTERIOR ###
find /opt/Backup/database -type d  -mtime +30 -exec rm -rf {} \;


### INICIAR NOVO BACKUP ###
TIMESTAMP=$(date +"%F")
USER="db_user"
PASSWORD="db_password"
OUTPUT="/opt/Backup/database/$TIMESTAMP"
REMOTO="/caminho_remoto/$TIMESTAMP"
mkdir -p "$OUTPUT/"
ssh host mkdir -p "$REMOTO"
databases=`mysql --user=$USER --password=$PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != _* ]] ; then
        echo "Dumping database: $db"
        mysqldump --single-transaction --events --force --opt --user=$USER --password=$PASSWORD --databases $db > $OUTPUT/`date +%Y%m%d-%H_%M`.$db.sql
        gzip $OUTPUT/`date +%Y%m%d-%H_%M`.$db.sql
    fi
done
cd "$OUTPUT"
scp *.sql.gz root@host_remoto:"$REMOTO"