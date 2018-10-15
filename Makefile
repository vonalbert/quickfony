COMPOSE=docker-compose
CMD=docker run --rm -v $(shell pwd):/app -w /app busybox
RUN=$(COMPOSE) run --rm app
EXEC=$(COMPOSE) exec app
SF=$(EXEC) bin/console

.PHONY: help

# Self-documenting makefile - https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


# ------------------------------------------------------
# Environment control
# ------------------------------------------------------
.PHONY: start stop build logs ports sh clean permissions restart

start: .env																												## Startup for development docker services
	@-$(COMPOSE) up -d --remove-orphans

stop: .env																												## Stop docker services
	@-$(COMPOSE) down

build: .env																												## Rebuild docker containers
	@-$(COMPOSE) build

logs:																													## Create and start docker containers in foreground
	@-$(COMPOSE) logs -f || true

ports:																													## Show ports used by the application. Require running containers.
	@-echo "Web-app:  $(shell $(COMPOSE) port reverse-proxy 80 | sed "s/0.0.0.0://")"
	@-echo "Traefik:  $(shell $(COMPOSE) port reverse-proxy 8080 | sed "s/0.0.0.0://")"
	@-echo "Database: $(shell $(COMPOSE) port database 3306 | sed "s/0.0.0.0://")"

sh:																														## Get access to the shell of the app container
	@-$(EXEC) bash || true

clean: 																													## Remove all the generated files, cache, logs, sessions and built assets
	@-$(CMD) rm -rf var vendor node_modules public/build public/bundles

permissions:																											## Change set current user as owner for all files (prevent permissions issues when developing on linux)
	@-$(CMD) chown -R $(shell id -u):$(shell id -g) .

restart: stop start																										## Kill and restart containers



# ------------------------------------------------------
# Proxy to containers' commands
# ------------------------------------------------------
.PHONY: cc db-update db-load watch test db

cc: 																													## Clear cache
	@-$(SF) cache:clear

db-update:																												## Update the database schema
	@-$(SF) doctrine:migrations:migrate --no-interaction

db-load:																												## Load fixtures into the database
	@-$(SF) doctrine:fixtures:load --no-interaction

watch:																													## Watch the assets and build their development version on change
	@-$(RUN) yarn run watch || true

test:																													## Run the full test suite
	@-$(RUN) bin/phpunit

db: db-update db-load																									## Update database to the latest version and load fixtures


# ------------------------------------------------------
# Build file targets
# ------------------------------------------------------
.env:
	@-$(CMD) cp -p .env.dist .env
