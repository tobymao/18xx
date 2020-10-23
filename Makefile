.DEFAULT_GOAL := dev_up

clean:
	sudo rm -rfv build/ public/assets/app.js public/assets/deps.js public/assets/engine.js public/assets/main.js public/assets/main.js.gz public/assets/opal.js

cleandeps:
	sudo rm -rfv public/assets/deps.js

# ensure ./db/data exists and is not owned by root
data_dir:
	./scripts/data_dir.sh

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
	docker-compose build
dev_up : dev_link data_dir
	docker-compose up
dev_up_b : dev_link data_dir
	docker-compose up --build

# prod config, run locally
prod_build : prod_link data_dir ensure_prod_env
	docker-compose build
prod_up : prod_link data_dir ensure_prod_env
	docker-compose up
prod_up_b : prod_link data_dir ensure_prod_env
	docker-compose up --build
prod_up_b_d : prod_link data_dir ensure_prod_env
	docker-compose up --build --detach

# remotely deploy latest master in prod
prod_deploy :
	./scripts/deploy_prod.sh
