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
	./ledger crear_usuario -n="Isabella Cruz" -b=1992-12-28
	./ledger crear_usuario -n="Mateo García" -b=1988-07-14
	./ledger crear_usuario -n="Sofía López" -b=1995-03-22
	./ledger crear_usuario -n="Liam Fernández" -b=1990-11-05
	./ledger crear_usuario -n="Valentina Martínez" -b=1985-09-30
	./ledger crear_usuario -n="Lucas Rodríguez" -b=1993-06-17
	./ledger crear_usuario -n="Camila González" -b=1998-01-09
	./ledger crear_usuario -n="Benjamín Sánchez" -b=1987-08-21
	./ledger crear_usuario -n="Emma Romero" -b=1994-05-12
	./ledger crear_usuario -n="Matías Torres" -b=1991-02-03
	./ledger crear_usuario -n="Amelia Díaz" -b=1989-12-15
	./ledger crear_usuario -n="Santiago Pérez" -b=1996-04-27
	./ledger crear_usuario -n="Mía Ramírez" -b=1992-10-08
	./ledger crear_usuario -n="Tomás Herrera" -b=1986-07-19
	./ledger crear_usuario -n="Victoria Castro" -b=1997-03-05
	./ledger crear_usuario -n="Martín Morales" -b=1990-09-23
	./ledger crear_usuario -n="Lucía Vega" -b=1993-11-11
	./ledger crear_usuario -n="Gabriel Ortiz" -b=1988-01-29
	./ledger crear_usuario -n="Valeria Cruz" -b=1995-06-06
	./ledger crear_usuario -n="Diego Flores" -b=1991-08-16
