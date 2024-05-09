# Script-Bach

This project uses a combination of Python, Docker, and MongoDB to generate and import a large amount of data.

## Prerequisites

- Docker
- Python 3

## Steps to Run the Project

### Step 1: Generate Data

Run the `data_generator.sh` script with the number of data rows you want to generate as an argument. For example, to generate 1,000,000 rows of data, you would run:

```bash
./data_generator.sh 1000000
```

This script uses Python and the Faker library to generate a CSV file with the specified number of rows. Each row contains a name, surname, and email.

### Step 2: Import Data with Docker

Once the data is generated, you can use Docker to import it into a MongoDB database. To do this, run:

```bash
docker-compose up
```

This command starts a MongoDB server and a `mongo-seed` service. The `mongo-seed` service runs the `mongoimport` command to import the generated data into the MongoDB database.

## Notes

The `docker-compose.yml` file in this project is configured to start the MongoDB server, run the `mongoimport` command, and then keep the MongoDB server running. This means that the data you imported will persist as long as the MongoDB server is running.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
