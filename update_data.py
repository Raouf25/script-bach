import os
import subprocess
import time
from pymongo import MongoClient, UpdateOne
from multiprocessing import Pool, cpu_count

def split_file_data():
    subprocess.run(["./split_file_data.sh", "1000", "./data-generation/db-seed/data_for_update.csv"])

def bulk_update(filename):
    client = MongoClient("mongodb://localhost:27017/")
    db = client["sammlerio"]
    bulk_updates = []

    filepath = os.path.join("./tmp", filename)

    with open(filepath, 'r') as file:
        for line in file:
            line = line.strip().split(',')
            if len(line) == 2:
                external_id, new_email = line
                filter_query = {"ExternalId": external_id}
                update_query = {"$set": {"Email": new_email}}
                bulk_updates.append(
                    UpdateOne(filter_query, update_query)
                )
            else:
                print(f"Ignoring invalid line: {line}")

    if bulk_updates:
        try:
            db.noms_prenoms_emails.bulk_write(bulk_updates)
            print(f"Updates applied successfully for {filename}.")
        except Exception as e:
            print(f"An error occurred while applying updates for {filename}: {e}")

def update_data():
    num_processes = cpu_count()
    with Pool(num_processes) as pool:
        files = [f for f in os.listdir("./tmp") if f.startswith('data_for_update_')]
        pool.map(bulk_update, files)

def main():
    start_time = time.time()

    split_file_data()
    update_data()

    end_time = time.time()
    execution_time = end_time - start_time
    print(f"Script execution time: {execution_time} seconds.")

if __name__ == "__main__":
    main()
