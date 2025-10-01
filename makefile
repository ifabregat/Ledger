.PHONY: setup-db stop-db

start-db:
	docker compose up -d
	
stop-db:
	docker compose down