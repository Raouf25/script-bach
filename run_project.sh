#!/bin/bash

# Run the data generator script then
# Run docker-compose
./data-generation/data_generator.sh 1000000 && docker-compose up
