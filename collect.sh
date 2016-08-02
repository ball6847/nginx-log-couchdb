#!/bin/sh

NGINX_ACCESS="/var/log/nginx/access.log"
TMP_FILENAME="/tmp/nginx_access_log"
COUCHDB_ENDPOINT="http://couchdb:5984/nginx_access_log"

# create log file if not exists
touch $NGINX_ACCESS

IFS='
'

while true
do
    SIZE="$(stat -c "%s" $NGINX_ACCESS)"

    if [ $SIZE != 0 ]; then
        LINE="$(cat $NGINX_ACCESS | wc -l)"
        BUFFER="$(sed -n "1,${LINE}p" < $NGINX_ACCESS)"

        for JSON in $BUFFER
        do
            curl -H 'Content-Type: application/json' \
                -X POST $COUCHDB_ENDPOINT \
                -d "$JSON"
        done

        tail -n +$LINE $NGINX_ACCESS > $NGINX_ACCESS
    fi

    # wait 1 sec to process another round
    sleep 1
done
