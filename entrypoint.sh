#!/bin/bash

# Set up the GitHub Actions runner
./config.sh --url $GITHUB_URL --token $RUNNER_TOKEN

# Start the runner
./run.sh
