.PHONY: db-connect db-migrate db-rollback

# Connect to PostgreSQL development database
dcnn:
	docker exec -it postgres-16 psql -U user -d multi_tenant_todo_development

# Run database migrations
dmgr:
	bin/rails db:migrate

# Rollback database migration
drbk:
	bin/rails db:rollback
