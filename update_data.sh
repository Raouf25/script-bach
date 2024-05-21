#!/bin/bash

# Path of files and directories
INPUT_FILE="./data-generation/db-seed/data_for_update.csv"
TMP_DIR="./tmp"
MONGO_URI="mongodb://localhost:27017/sammlerio"
CHUNK_SIZE=5000

# Check if the input file exists
if [ ! -f "$INPUT_FILE" ]; then
    printf "Error: The input file does not exist\n"
    exit 1
fi

# Create the temporary directory if it does not exist
mkdir -p $TMP_DIR

start_time=$(date +%s)

# Split the file by the specified number of lines (CHUNK_SIZE)
split -l $CHUNK_SIZE -d -a 4 $INPUT_FILE $TMP_DIR/data_for_update_

# Create a process for each file, limiting the number of simultaneous processes to half the number of available processors
#find $TMP_DIR/data_for_update_* | xargs -n1 -P$(nproc --all) -I{} ./add_bulk_update_ops.sh {}
find $TMP_DIR/data_for_update_* | xargs -n1 -P$(nproc --all) -I{} bash -c './add_bulk_update_ops.sh {}; rm {}'


# Check if mongosh is installed, if not install it
if ! command -v mongosh &> /dev/null; then
    printf "mongosh is not installed. Installing...\n"
    brew tap mongodb/brew
    brew update
    brew install mongodb-community@7.0
fi
# Execute the MongoDB script for each file, limiting the number of simultaneous processes to half the number of available processors
#find $TMP_DIR/data_for_update_*js | xargs -n1 -P$(nproc --all) -I{} bash -c 'mongosh '"$MONGO_URI"' "$@"' _ {}
find $TMP_DIR/data_for_update_*js | xargs -n1 -P$(nproc --all) -I{} bash -c 'mongosh '"$MONGO_URI"' "$@"; echo "$@"; rm "$@"' _ {}

# Cleanup
#rm -rf $TMP_DIR

end_time=$(date +%s)
execution_time=$((end_time - start_time))
printf "Script execution time: $execution_time seconds.\n"

# pour 100_000 données, le temps d'exécution est de 629 secondes. (10 minutes et 29 secondes)
# c'est à dire une ligne en 0,00629 secondes

# pour 100_000 données, le temps d'exécution est de 568 secondes. (9 minutes et 29 secondes)
# c'est à dire une ligne en 0,00568 secondes
