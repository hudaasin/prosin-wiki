######################################################
#            Docker Container Management             #
######################################################
# Build the containers
build:
	docker compose -f ./compose.yml up --build -d --remove-orphans --force-recreate

# Start the Docker containers defined in the specified configuration file in detached mode.
up:
	docker compose -f ./compose.yml up -d

# Stop and remove the containers
down:
	docker compose -f ./compose.yml down

# Display the logs of the Docker containers defined in the specified configuration file.
logs: up
	docker compose -f ./compose.yml logs

configs:
	docker compose -f ./compose.yml config

.PHONY: build up down logs configs
