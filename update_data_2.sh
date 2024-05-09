#!/bin/bash

mongoimport --host localhost --port 27017 --db sammlerio --mode upsert --type csv --file ./data-generation/db-seed/noms_prenoms_emails.csv --headerline

# Vérifier si mongosh est installé, sinon l'installer
if ! command -v mongosh &> /dev/null; then
    echo "mongosh n'est pas installé. Installation en cours..."
    brew tap mongodb/brew
    brew update
    brew install mongodb-community@7.0
fi

start_time=$(date +%s)

# split File divided file lines number by the number of processors available
chunk=$(( $(wc -l < ./data-generation/db-seed/noms_prenoms_emails.csv) / $(nproc --all)/2 ))
./split_file_data.sh "$chunk" ./data-generation/db-seed/data_for_update.csv

# update  data base
MONGO_URI="mongodb://localhost:27017/sammlerio"

# Créer un processus pour chaque fichier en limitant le nombre de processus simultanés à 10
num_processes=0
for fichier_csv in ./tmp/data_for_update_*; do
        (
            # Construction du script pour les mises à jour en masse
            filename=$(basename $fichier_csv)
            # Extract the file number based on the last underscore
            file_number=$(echo "$filename" | rev | cut -d'_' -f 1 | rev | sed 's/^0*//' | awk '{if ($0 == "") print "0"; else print $0}')
            bulk_update_script=./tmp/"bulk_update_$file_number.js"

            # Création du script de mise à jour en masse
            echo "var bulkUpdateOps = [];" > $bulk_update_script
            awk 'BEGIN {FS=","} {gsub(/\r/,""); print "bulkUpdateOps.push({ updateOne: { filter: { '\''ExternalId'\'': '\''" $1 "'\'' }, update: { \$set: { '\''Email'\'': '\''" $2 "'\'' } } } });"}' $fichier_csv >> $bulk_update_script
            echo "db.noms_prenoms_emails.bulkWrite(bulkUpdateOps);" >> $bulk_update_script
#            echo "print('La mise à jour de $bulk_update_script est terminée.');" >> $bulk_update_script
        ) &
        num_processes=$((num_processes + 1))

        # Limiter le nombre de processus simultanés au nombre de processeurs disponibles dans le système
        if [ $num_processes -ge $(nproc --all) ]; then
            wait && num_processes=0
        fi
done
rm -rf ./tmp/data_for_update_*

num_processes=0
total=$(ls -l ./tmp/bulk_update_* | wc -l)
for bulk_update_script_js in ./tmp/bulk_update_*; do
        (
            # Exécution du script MongoDB
            mongosh $MONGO_URI $bulk_update_script_js && file_number=$(echo "$bulk_update_script_js" | sed 's/[^0-9]*//g') && ./progress_bar.sh "$total" "$file_number" "$total"  && rm $bulk_update_script_js
        ) &
        num_processes=$((num_processes + 1))

        # Limiter le nombre de processus simultanés au nombre de processeurs disponibles dans le système
        if [ $num_processes -ge $(nproc --all) ]; then
            wait && num_processes=0
        fi
done

wait
./progress_bar.sh "$total" "$total"  "$total"

if [ -z "$(ls -A ./tmp)" ]; then
    rm -rf ./tmp
fi

end_time=$(date +%s)
execution_time=$((end_time - start_time))
echo -e "\nDurée d'exécution du script: $execution_time secondes."
# pour 100_000 données, le temps d'exécution est de  629 secondes. (10 minutes et 29 secondes)
# c'est à dire une ligne en 0,00629 secondes
