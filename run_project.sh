#!/bin/bash

# Generate data file
# Run docker-compose
./data-generation/data_generator.sh 100000

docker-compose up
