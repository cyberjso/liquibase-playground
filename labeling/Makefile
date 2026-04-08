COMPOSE = docker compose
LIQUIBASE_RUN = $(COMPOSE) run --rm liquibase --defaultsFile=/workspace/liquibase.properties

.PHONY: start migrate migrate-labels status history stop clean psql

start:
	$(COMPOSE) up -d postgres

migrate:
	@if [ -n "$(LABELS)" ]; then \
		$(LIQUIBASE_RUN) update --labels="$(LABELS)"; \
	else \
		$(LIQUIBASE_RUN) update; \
	fi

status:
	@if [ -n "$(LABELS)" ]; then \
		$(LIQUIBASE_RUN) status --verbose --labels="$(LABELS)"; \
	else \
		$(LIQUIBASE_RUN) status --verbose; \
	fi

history:
	$(LIQUIBASE_RUN) history

psql:
	$(COMPOSE) exec postgres psql -U label_user -d label_lab

stop:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v
