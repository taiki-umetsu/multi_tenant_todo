.PHONY: db-connect db-migrate db-rollback tt bm rc pg17-remove pg17-start pg17-stop

# Connect to PostgreSQL development database
dcnn:
	docker exec -it postgres-17 psql -U user -d multi_tenant_todo_development

# Run database migrations
dmgr:
	bin/rails db:migrate

# Rollback database migration
drbk:
	bin/rails db:rollback

tt:
	bundle exec rspec

bm:
	bundle exec brakeman

rc:
	bundle exec rubocop -a

# PostgreSQL 17 コンテナを停止、削除、ボリュームを削除
pg17-remove:
	docker stop postgres-17
	docker rm postgres-17
	docker volume rm multi_tenant_todo_pgdata17

pg17-start:
	docker compose -f docker-compose-pg17.yml up -d

pg17-stop:
	docker stop postgres-17
