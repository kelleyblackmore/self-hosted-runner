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
