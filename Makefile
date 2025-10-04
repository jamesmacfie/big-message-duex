''.PHONY: help setup install db-create db-migrate db-seed db-seed-test db-reset db-setup console server test docker-up docker-down docker-logs clean generate-model generate-controller generate-migration rails

# Default shell
SHELL := /bin/bash

# Ruby environment
export PATH := $(HOME)/.gem/ruby/3.4.5/bin:$(HOME)/.rubies/ruby-3.4.5/bin:$(PATH)

# Help command
help:
	@echo "Big Message - Available Commands"
	@echo ""
	@echo "Setup & Installation:"
	@echo "  make setup         - Complete project setup (install deps, docker, db)"
	@echo "  make install       - Install Ruby dependencies"
	@echo ""
	@echo "Database:"
	@echo "  make db-create     - Create database"
	@echo "  make db-migrate    - Run migrations"
	@echo "  make db-seed       - Seed database with test data"
	@echo "  make db-seed-test  - Seed database with test data (alias)"
	@echo "  make db-reset      - Reset database (drop, create, migrate, seed)"
	@echo "  make db-setup      - Setup database (create, migrate, seed)"
	@echo ""
	@echo "Docker:"
	@echo "  make docker-up     - Start Docker services (postgres, redis)"
	@echo "  make docker-down   - Stop Docker services"
	@echo "  make docker-logs   - View Docker logs"
	@echo ""
	@echo "Development:"
	@echo "  make server        - Start Rails server"
	@echo "  make console       - Open Rails console"
	@echo "  make test          - Run tests"
	@echo ""
	@echo "Generators:"
	@echo "  make generate-model NAME=User attrs='email:string'"
	@echo "  make generate-controller NAME=Sessions actions='new create'"
	@echo "  make generate-migration NAME=AddFieldToTable"
	@echo "  make rails cmd='db:migrate'"
	@echo ""
	@echo "Utilities:"
	@echo "  make clean         - Clean tmp and log files"

# Setup & Installation
setup: docker-up install db-setup
	@echo "✅ Setup complete! Run 'make server' to start the application"

install:
	bundle install

# Database commands
db-create:
	bin/rails db:create

db-migrate:
	bin/rails db:migrate

db-seed:
	bin/rails db:seed

db-seed-test: db-seed

db-reset:
	bin/rails db:drop db:create db:migrate db:seed

db-setup: db-create db-migrate db-seed

# Docker commands
docker-up:
	docker-compose up -d
	@echo "⏳ Waiting for services to be ready..."
	@sleep 3

docker-down:
	docker-compose down

docker-logs:
	docker-compose logs -f

# Development commands
server:
	bin/dev

console:
	bin/rails console

test:
	bin/rails test

# Generators
generate-model:
	@if [ -z "$(NAME)" ]; then \
		echo "❌ Error: NAME is required. Usage: make generate-model NAME=User attrs='email:string'"; \
		exit 1; \
	fi
	bin/rails generate model $(NAME) $(attrs)

generate-controller:
	@if [ -z "$(NAME)" ]; then \
		echo "❌ Error: NAME is required. Usage: make generate-controller NAME=Sessions actions='new create'"; \
		exit 1; \
	fi
	bin/rails generate controller $(NAME) $(actions)

generate-migration:
	@if [ -z "$(NAME)" ]; then \
		echo "❌ Error: NAME is required. Usage: make generate-migration NAME=AddFieldToTable"; \
		exit 1; \
	fi
	bin/rails generate migration $(NAME)

# Generic rails command runner
rails:
	@if [ -z "$(cmd)" ]; then \
		echo "❌ Error: cmd is required. Usage: make rails cmd='db:migrate'"; \
		exit 1; \
	fi
	bin/rails $(cmd)

# Utilities
clean:
	rm -rf tmp/cache/*
	rm -rf log/*.log
	@echo "✅ Cleaned tmp and log files"
