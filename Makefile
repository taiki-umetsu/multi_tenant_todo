.PHONY: db-connect db-migrate db-rollback tt bm rc precommit pg17-remove pg17-start pg17-stop

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

# コミット前のチェック（rubocop自動修正 + brakeman + test）
precommit:
	@echo "Running pre-commit checks..."
	@echo "1. Running RuboCop with auto-correct..."
	bundle exec rubocop -a
	@echo "2. Running Brakeman security scan..."
	bundle exec brakeman
	@echo "3. Running tests..."
	bundle exec rspec
	@echo "All checks passed! Ready to commit."

# PostgreSQL 17 コンテナを停止、削除、ボリュームを削除
pg17-remove:
	docker stop postgres-17
	docker rm postgres-17
	docker volume rm multi_tenant_todo_pgdata17

pg17-start:
	docker compose -f docker-compose-pg17.yml up -d

pg17-stop:
	docker stop postgres-17
