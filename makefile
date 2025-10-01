.PHONY: start-db stop-db setup-db reset-db migraciones format compilar dev

start-db:
	docker compose up -d

stop-db:
	docker compose down

setup-db:
	mix ecto.create
	mix ecto.migrate

reset-db:
	mix ecto.drop
	mix ecto.create
	mix ecto.migrate

migraciones:
	mix ecto.migrate

format:
	mix format

compilar:
	mix escript.build

dev:
	iex -S mix