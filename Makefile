.PHONY: db-connect db-migrate db-rollback tt bm rc

# Connect to PostgreSQL development database
dcnn:
	docker exec -it postgres-17 psql -U multi_tenant_app -d multi_tenant_todo_development

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
