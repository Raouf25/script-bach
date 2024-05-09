import csv
import sys
import os
import faker
from unidecode import unidecode

def anonymize_email(email):
    username, domain = email.split('@')
    username = username[0] + 'x' * (len(username) - 1)
    return f"{username}@{domain}"

def generer_csv(nb_lignes,  output_1_csv, output_2_csv):
    fake = faker.Faker('fr_FR')

    with open(output_1_csv, 'w', newline='') as init_data_csv, open(output_2_csv, 'w', newline='') as update_data_csv:
        writer1 = csv.writer(init_data_csv)
        writer1.writerow(['LastName', 'FirstName', 'ExternalId', 'Email'])

        writer2 = csv.writer(update_data_csv)
        writer2.writerow(['ExternalId', 'AnonymizedEmail'])

        for _ in range(nb_lignes):
            nom = fake.name()
            prenom = fake.first_name()
            external_id = fake.uuid4()
            domaine = fake.domain_word() + '.' + fake.tld()
            email = f"{unidecode(prenom.lower())}.{unidecode(nom.lower())}@{domaine}".replace(' ', '')
            anonymized_email = anonymize_email(email)
            writer1.writerow([nom, prenom, external_id, email])
            writer2.writerow([external_id, anonymized_email])

if __name__ == "__main__":
    nb_lignes = int(sys.argv[1])

    # Get the parent directory of the current script's absolute path
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_1_csv = os.path.join(script_dir, "./db-seed/noms_prenoms_emails.csv")
    output_2_csv = os.path.join(script_dir, "./db-seed/data_for_update.csv")

    generer_csv(nb_lignes, output_1_csv, output_2_csv)
