#!/bin/bash

# Chemin des fichiers
DATA_FILE="./data-generation/db-seed/noms_prenoms_emails.csv"
TMP_DIR="./tmp"
UPDATE_SCRIPT_PREFIX="$TMP_DIR/bulk_update_"
CHUNK_PREFIX="$TMP_DIR/data_for_update_"

# Import initial
mongoimport --host localhost --port 27017 --db sammlerio --mode upsert --type csv --file $DATA_FILE --headerline

# Vérifier si mongosh est installé, sinon l'installer
if ! command -v mongosh &> /dev/null; then
    echo "mongosh n'est pas installé. Installation en cours..."
    brew tap mongodb/brew
    brew update
    brew install mongodb-community@7.0
fi

start_time=$(date +%s)

# Créer le répertoire temporaire si non existant
mkdir -p $TMP_DIR

# Diviser le fichier par le nombre de processeurs disponibles
chunk_size=$(( $(wc -l < $DATA_FILE) / $(nproc --all) / 2 ))
split -l $chunk_size -d -a 4 $DATA_FILE $CHUNK_PREFIX

# Fonction pour créer des scripts de mise à jour en masse
create_bulk_update_script() {
    local file=$1
    local script=$2
    echo "var bulkUpdateOps = [];" > $script
    awk 'BEGIN {FS=","} {gsub(/\r/,""); print "bulkUpdateOps.push({ updateOne: { filter: { '\''ExternalId'\'': '\''" $1 "'\'' }, update: { \$set: { '\''Email'\'': '\''" $2 "'\'' } } } });"}' $file >> $script
    echo "db.noms_prenoms_emails.bulkWrite(bulkUpdateOps);" >> $script
}

# Créer et exécuter les scripts de mise à jour en parallèle
export MONGO_URI="mongodb://localhost:27017/sammlerio"
export -f create_bulk_update_script
ls $CHUNK_PREFIX* | xargs -n 1 -P $(nproc --all) -I {} bash -c 'create_bulk_update_script {} '$UPDATE_SCRIPT_PREFIX'$(basename {})'

# Exécuter les scripts de mise à jour MongoDB
ls $UPDATE_SCRIPT_PREFIX* | xargs -n 1 -P $(nproc --all) mongosh $MONGO_URI

# Nettoyage
rm -rf $TMP_DIR

end_time=$(date +%s)
execution_time=$((end_time - start_time))
echo -e "\nDurée d'exécution du script: $execution_time secondes."
