#!/bin/bash

function add_bulk_update_ops() {
    local file=$1
    local update_script="./tmp/$(basename ${file}).js"
    printf "var bulk3 = db.noms_prenoms_emails.initializeOrderedBulkOp();" > $update_script
    awk 'BEGIN {FS=","} {gsub(/\r/,""); print "bulk3.find({ \"ExternalId\": \"" $1 "\" }).updateOne({ \$set: { \"Email\": \"" $2 "\" } });"}' $file >> $update_script
    printf "bulk3.execute();" >> $update_script
}

add_bulk_update_ops "$@"
