
.PHONY: test up down busted

test: up busted down

busted:
	busted .

up:
	docker compose up -d --wait --wait-timeout 10 --no-log-prefix

down:
	docker compose down --remove-orphans
