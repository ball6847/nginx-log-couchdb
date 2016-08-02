#!/bin/sh

NGINX_ACCESS="/var/log/nginx/access.log"
TMP_FILENAME="/tmp/nginx_access_log"
COUCHDB_ENDPOINT="http://couchdb:5984/nginx_access_log"

# create log file if not exists
touch $NGINX_ACCESS

# check access log file existence
while true
do
    if [ -f "$NGINX_ACCESS" ]; then
        # rename to new file
        mv $NGINX_ACCESS $TMP_FILENAME

        # force nginx to create new log file
        nginx -s reload

        # process the file line by line
        while read -r JSON
        do
            curl -H 'Content-Type: application/json' \
                -X POST $COUCHDB_ENDPOINT \
                -d "$JSON"

        done < $TMP_FILENAME

        # clear file when finished
        rm -f $TMP_FILENAME
    fi

    # wait 1 sec to process another round
    sleep 1
done
