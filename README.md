# Script-Bach
# Project Overview

This project is a robust data generation and management system that leverages the power of Python, Docker, and MongoDB. It is designed to generate a large amount of data, import it into a MongoDB database, and provide an interface for updating the data. The project is structured around two main scripts: `run_project.sh` and `update_data.sh`.

## Prerequisites

Before you can run this project, you will need to have the following installed on your system:

- Docker
- Python 3
- MongoDB
- Bash

## Running the Project

Running the project involves two main steps:

### Step 1: Generate and Import Data

The first step is to generate the data and import it into MongoDB. This is done using the `run_project.sh` script. This script checks if Docker is installed and running, starts the Docker services, generates the data file, and imports the data into MongoDB.

To run the script, navigate to the project directory in your terminal and execute the following command:

```bash
./run_project.sh
```

### Step 2: Update Data

The second step is to update the data in MongoDB. This is done using the `update_data.sh` script. This script checks if mongosh is installed, splits the input file into several smaller files, adds bulk update operations to each file, executes the generated MongoDB scripts, and cleans up the temporary files.

To run the script, navigate to the project directory in your terminal and execute the following command:

```bash
./update_data.sh
```

## Conclusion

This project provides a powerful and flexible system for generating, importing, and updating large amounts of data. Whether you're working with a small dataset for a personal project or managing a large database for a production application, this project provides the tools you need to handle your data efficiently and effectively.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
