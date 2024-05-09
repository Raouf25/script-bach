#!/bin/bash

# Vérifier si Python 3 est installé
if ! command -v python3 &>/dev/null; then
  echo "Python 3 n'est pas installé. Installation en cours..."
  if command -v apt-get &>/dev/null; then
    sudo apt-get install -y python3
  elif command -v yum &>/dev/null; then
    sudo yum install -y python3
  else
    echo "Erreur: Le gestionnaire de paquets n'est pas supporté."
    exit 1
  fi
fi

# Vérifier la version de pip
pip_version=$(python3 -m pip --version | awk '{print $2}')

# Si la version de pip est inférieure à 21.3, mettre à niveau pip
if [ "$(printf '%s\n' "21.3" "$pip_version" | sort -V | head -n1)" != "21.3" ]; then
  echo "Mise à niveau de pip en cours..."
  python3 -m pip install --quiet --upgrade pip
fi

# Vérifier le nombre d'arguments
if [ $# -ne 1 ]; then
  echo "Usage: $0 <nombre_lignes>"
  exit 1
fi

# Définir le nombre de lignes et le nom du fichier
nb_lignes=$1
fichier_csv="noms_prenoms_emails.csv"

# Vérifier et installer Faker si nécessaire
if ! python3 -m pip show faker &>/dev/null; then
  python3 -m pip install --quiet faker
fi

# Vérifier et installer Unidecode si nécessaire
if ! python3 -m pip show unidecode &>/dev/null; then
  python3 -m pip install --quiet unidecode
fi

# Obtenir le répertoire parent du chemin absolu du script courant
SCRIPT_DIR=$(dirname $(readlink -f "$0"))

# Exécuter le script Python en passant le nombre de lignes en argument
python3 $SCRIPT_DIR/generer_noms_prenoms_emails.py $nb_lignes

echo "Fichier CSV créé: $fichier_csv  avec $nb_lignes lignes"
