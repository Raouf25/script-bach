#!/bin/bash

start_time=$(date +%s)

# split File
./split_file_data.sh  500  ./data-generation/db-seed/data_for_update.csv


# Vérifier si mongosh est installé, sinon l'installer
if ! command -v mongosh &> /dev/null; then
    echo "mongosh n'est pas installé. Installation en cours..."
    brew tap mongodb/brew
    brew update
    brew install mongodb-community@7.0
fi

# update  data base
MONGO_URI="mongodb://localhost:27017/sammlerio"

# Créer un processus pour chaque fichier en limitant le nombre de processus simultanés à 10
num_processes=0
for fichier_csv in ./tmp/data_for_update_*; do
        (
#            echo $fichier_csv

            # Construction du script pour les mises à jour en masse
            filename=$(basename $fichier_csv)
            # Extract the file number based on the last underscore
            file_number=$(echo "$filename" | rev | cut -d'_' -f 1 | rev)
            bulk_update_script=./tmp/"bulk_update_$file_number.js"

            # Création du script de mise à jour en masse
            echo "var bulkUpdateOps = [];" > $bulk_update_script

            # Lecture du fichier CSV et construction des opérations de mise à jour en masse
            while IFS=',' read -r externalId email || [ -n "$externalId" ];
            do
                email=$(echo $email | awk '{gsub(/\r/,"")} {print}')
                #mongosh "$MONGO_URI" --eval "db.noms_prenoms_emails.updateOne({ ExternalId: \"$externalId\" }, { \$set: { Email: \"$email\" } });"
                echo "bulkUpdateOps.push({ updateOne: { filter: { 'ExternalId': '$externalId' }, update: { \$set: { 'Email': '$email' } } } });" >> $bulk_update_script
            done < $fichier_csv

            # Exécution des mises à jour en masse
            echo "db.noms_prenoms_emails.bulkWrite(bulkUpdateOps);" >> $bulk_update_script
            echo "print('La mise à jour de $bulk_update_script est terminée.');" >> $bulk_update_script

            # Exécution du script MongoDB
            mongosh $MONGO_URI $bulk_update_script  && rm $bulk_update_script
        ) &
        num_processes=$((num_processes + 1))

        # Limiter le nombre de processus simultanés au nombre de processeurs disponibles dans le système
        if [ $num_processes -ge $(nproc --all) ]; then
            wait && num_processes=0
        fi
done

rm -rf ./tmp/data_for_update_*
wait

end_time=$(date +%s)
execution_time=$((end_time - start_time))
echo "Durée d'exécution du script: $execution_time secondes."
