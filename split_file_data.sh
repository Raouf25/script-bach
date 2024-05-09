#!/bin/bash

# This script splits a file into multiple smaller files.
# Usage: ./split_file_data.sh line_number input_file

## Check that the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Error: Incorrect number of arguments"
    echo "Usage: ./split_file_data.sh line_number input_file"
    exit 1
fi

line_number=$1
input_file=$2

# Extraire le nom de fichier sans extension
nom_fichier=$(basename "$input_file" .csv)
output_file_prefix="${nom_fichier}_"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: Input file does not exist"
    exit 1
fi

# Check if the ./tmp directory exists, if not create it
if [ ! -d "./tmp" ]; then
    mkdir ./tmp
fi

# Split the input file
# split -l 5 -d  ./data-generation/db-seed/data_for_update.csv  ./tmp/data_for_update_split_file_
split -l $line_number -d $input_file ./tmp/$output_file_prefix

# Message de confirmation
echo "Fichier '$input_file' est divisé en plusieurs fichiers dans le répertoire './tmp' avec le nom de base '$output_file_prefix'."
