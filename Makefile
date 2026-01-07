down: 
	docker compose down -v --remove-orphans
up: 
	docker compose up --build api frontend database adminer

it:
	docker compose run -it api bash

current:
	docker compose exec -it api poetry run alembic -c backend/alembic.ini current

migrate:
	docker compose exec -it api poetry run alembic -c backend/alembic.ini revision --autogenerate -m "${m}"

migrations:
	docker compose exec -it api poetry run alembic -c backend/alembic.ini upgrade head

create_admin:
	docker compose up --build initialize_admin -d
popular:
	docker compose exec -it api poetry run python backend/src/seed.py

test:
	docker compose exec -it api poetry run pytest

install:
	poetry install
	
setup: install up migrations create_admin popular test 
