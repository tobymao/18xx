.DEFAULT_GOAL := dev_up_b
CONTAINER_COMPOSE ?= $(CONTAINER_ENGINE)-compose
CONTAINER_ENGINE ?= docker

clean:
	sudo rm -rfv build/ public/assets/*.js public/assets/*.js.gz public/assets/version.json

cleandeps:
	sudo rm -rfv public/assets/deps.js

# ensure ./db/data exists and is not owned by root
data_dir:
	./scripts/data_dir.sh $(CONTAINER_ENGINE)

# ensure the required environment variables exist when running with prod config
ensure_prod_env:
	./scripts/ensure_prod_env.sh

# manage the override symlink
clean_link:
	rm -f docker-compose.override.yml
dev_link : clean_link
	ln -s docker-compose.dev.yml docker-compose.override.yml
prod_link : clean_link
	ln -s docker-compose.prod.yml docker-compose.override.yml

# dev config, run locally
dev_build : dev_link data_dir
	$(CONTAINER_COMPOSE) build
dev_up : dev_link data_dir
	$(CONTAINER_COMPOSE) up
dev_up_b : dev_link data_dir
	$(CONTAINER_COMPOSE) up --build

# prod config, run locally
prod_build : prod_link data_dir ensure_prod_env
	$(CONTAINER_COMPOSE) build
prod_up : prod_link data_dir ensure_prod_env
	$(CONTAINER_COMPOSE) up
prod_up_b : prod_link data_dir ensure_prod_env
	$(CONTAINER_COMPOSE) up --build
prod_up_b_d : prod_link data_dir ensure_prod_env
	$(CONTAINER_COMPOSE) up --build --detach
prod_rack_up_b_d : prod_link data_dir ensure_prod_env
	$(CONTAINER_COMPOSE) up --build --no-deps --detach rack && \
		$(CONTAINER_COMPOSE) up --build --no-deps --detach queue && \
		sleep 20 && \
		$(CONTAINER_COMPOSE) up --build --no-deps --detach rack_backup

# remotely deploy latest master in prod
prod_deploy : clean
	$(CONTAINER_COMPOSE) run rack rake precompile && \
		rsync --verbose --checksum public/assets/*.js public/assets/*.js.gz public/assets/version.json deploy@18xx:~/18xx/public/assets/ && \
		ssh -l deploy 18xx "source ~/.profile && cd ~/18xx/ && git pull && make prod_rack_up_b_d"

style:
	$(CONTAINER_COMPOSE) exec rack rubocop -A

test:
	$(CONTAINER_COMPOSE) exec rack rake
