#!/bin/bash

# Variables
DB_HOST="localhost"
DB_PORT="27017"
DB_NAME="sammlerio"
DATA_FILE="./data-generation/db-seed/noms_prenoms_emails.csv"

# Vérifier si Docker est installé et en cours d'exécution
if ! command -v docker &> /dev/null; then
    echo "Erreur : Docker n'est pas installé."
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "Erreur : Docker n'est pas en cours d'exécution."
    exit 1
fi

# Démarrer les services Docker
docker-compose up -d

# Générer le fichier de données
./data-generation/data_generator.sh 100000

# Vérifier si le fichier de données existe
if [ ! -f "$DATA_FILE" ]; then
    echo "Erreur : Le fichier de données n'existe pas."
    exit 1
fi

# Importer les données dans MongoDB
mongoimport --host $DB_HOST --port $DB_PORT --db $DB_NAME --mode upsert --type csv --file $DATA_FILE --headerline && echo "Les données ont été importées dans la base de données."
