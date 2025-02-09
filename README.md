# self-hosted-runner

This repository contains a Dockerized setup for a self-hosted GitHub Actions runner. The runner is configured to work with GitHub and can be customized as needed.

## Directory Layout
```
self-hosted-runner/
├─ Dockerfile
└─ entrypoint.sh
```

## Dockerfile
```Dockerfile
# Use any base you like; Ubuntu is common
FROM ubuntu:22.04

# Install needed dependencies
RUN apt-get update && \
    apt-get install -y curl git jq && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user for running the actions
RUN useradd -m runner

# Set a work directory
WORKDIR /home/runner

# Set environment variables for the runner version and architecture
ENV RUNNER_VERSION=2.322.0
ENV RUNNER_ARCH=linux-x64

# Download and extract the GitHub Actions runner
RUN curl -o actions-runner.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz && \
    tar xzf actions-runner.tar.gz && \
    rm actions-runner.tar.gz

# Copy the entrypoint script
COPY entrypoint.sh /home/runner/entrypoint.sh

# Give execution rights on the entrypoint script
RUN chmod +x /home/runner/entrypoint.sh

# Switch to the runner user
USER runner

# Set the entrypoint
ENTRYPOINT ["/home/runner/entrypoint.sh"]
```

## entrypoint.sh
```bash
#!/bin/bash

# Validate required environment variables
if [ -z "$GITHUB_RUNNER_TOKEN" ]; then
  echo "GITHUB_RUNNER_TOKEN is not set"
  exit 1
fi

if [ -z "$GITHUB_RUNNER_URL" ]; then
  echo "GITHUB_RUNNER_URL is not set"
  exit 1
fi

if [ -z "$RUNNER_NAME" ]; then
  echo "RUNNER_NAME is not set"
  exit 1
fi

# Configure the runner
./config.sh --url "$GITHUB_RUNNER_URL" --token "$GITHUB_RUNNER_TOKEN" --name "$RUNNER_NAME" --work "_work" --replace

# Run the runner
./run.sh
```

## Building the Image
To build the Docker image, run the following command in the repository's root directory:
```
docker build -t self-hosted-runner:latest .
```

## Running the Container
To run the Docker container, you need to set the following environment variables:
- `GITHUB_RUNNER_TOKEN`: The registration token for the GitHub runner.
- `GITHUB_RUNNER_URL`: The URL of the GitHub repository or organization.
- `RUNNER_NAME`: The name of the runner.
- `RUNNER_LABELS`: Optional labels for the runner.

Run the container with the following command:
```
docker run -d \
  -e GITHUB_RUNNER_TOKEN=<your_token> \
  -e GITHUB_RUNNER_URL=<your_github_url> \
  -e RUNNER_NAME=<your_runner_name> \
  -e RUNNER_LABELS=<your_labels> \
  self-hosted-runner:latest
```

Replace `<your_token>`, `<your_github_url>`, `<your_runner_name>`, and `<your_labels>` with your specific values.
