.DEFAULT_GOAL := dev_up

.PHONY: ensure_env_prod build dev_up prod_up prod_deploy down

# validate required variables in .env
ensure_env_prod:
	./scripts/ensure_env.sh production

# build docker images
build:
	./scripts/build_images.sh development
build_prod:
	./scripts/build_images.sh production

# start docker stack
dev_up_s:
	./scripts/ensure_env.sh development
	./scripts/data_dir.sh development
	./scripts/stack_up.sh development
prod_up:
	./scripts/ensure_env.sh production
	./scripts/data_dir.sh production
	./scripts/stack_up.sh production

# bring down docker stack, prod or dev
down:
	docker stack rm 18xx

# manage dev stack with compose instead of swarm
dev_up:
	./scripts/ensure_env.sh development
	./scripts/data_dir.sh development
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
dev_up_b:
	./scripts/ensure_env.sh development
	./scripts/data_dir.sh development
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml up --build
build_dev:
	docker-compose -f docker-compose.yml -f docker-compose.dev.yml build
dev_down:
	docker-compose down


# remotely deploy latest master in prod
prod_deploy:
	./scripts/prod_deploy.sh
