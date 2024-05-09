#!/bin/bash

# Define MongoDB connection parameters
HOST="localhost"
PORT="27017"
DB="sammlerio"

# Define MongoDB bulkWrite operation
BULK_WRITE='
    var bulk = db.mycollection.initializeOrderedBulkOp();
    bulk.insert( { "name": "John Doe", "age": 30 } );
    bulk.insert( { "name": "Jane Smith", "age": 25 } );
    bulk.execute();
'

# Execute MongoDB bulkWrite operation
mongo --host $HOST --port $PORT $DB --eval "$BULK_WRITE"
