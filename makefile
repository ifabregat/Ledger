.PHONY: up-db down-db setup-db reset-db migrate format compile dev

up-db:
	docker compose up -d

down-db:
	docker compose down

setup-db:
	mix ecto.create
	mix ecto.migrate

reset-db:
	mix ecto.drop
	mix ecto.create
	mix ecto.migrate

migrate:
	mix ecto.migrate

format:
	mix format

compile: format
	mix escript.build

dev:
	iex -S mix

insert-db:
	./usuarios.sh
	./monedas.sh
