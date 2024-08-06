
.PHONY: test up down busted

test: up busted down

busted:
	busted-5.3 .
	busted-5.1 --no-auto-insulate .

up:
	docker compose up -d --wait --wait-timeout 10 --no-log-prefix

down:
	docker compose down --remove-orphans
