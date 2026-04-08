# Liquibase Labeling Test Lab

This folder contains a PostgreSQL + Liquibase playground to test label-based release execution.

## Why labels?

In a monolithic database shared by multiple teams, not every team ships at the same cadence. A backend team might be ready to deploy `release-1` (new sequences, indexes, and seed data) while a platform team is still stabilising `release-2` (audit event tables). Without a coordination mechanism, the only options are:

- **Deploy everything** — risky when some changesets aren't ready for production yet.
- **Comment out changesets** — error-prone and breaks the changelog history.

Liquibase labels solve this cleanly. Each changeset can carry one or more label tags. When you run migrations you pass a label filter, and only matching changesets execute. Changesets with **no label** always execute regardless of the filter — they represent shared infrastructure that every environment needs.

This lets teams work on the same changelog file independently and deploy their own slices of changes on their own schedule, without blocking each other.

## Model

The schema uses a simple work tracking model in schema `lab`:

- `lab.labels`, `lab.work_items`, `lab.work_item_labels` — core tables (no label, always deployed)
- sequences for IDs — tagged `release-1`
- indexes for common lookups — tagged `release-1`
- seed data — tagged `release-1`
- `lab.release2_audit_events` — tagged `release-2`
- `lab.deployment_notes` — no label, always deployed
- one function and one stored procedure — no label, `runOnChange`

Routine definitions are stored in `changelog/routines` and configured with Liquibase `runOnChange`, so they re-apply only when their file content changes.

The Liquibase image build file is at `labeling/Dockerfile`.

## Prerequisites

- **Docker Engine 20.10+** (or Docker Desktop) with the **Compose plugin** (`docker compose` v2)
- **GNU Make**

The Liquibase container image is built automatically on first use (`docker compose build`). No local Java or Liquibase installation is required.

## Commands

Start PostgreSQL:

```bash
make start
```

Run all migrations (no label filter — every changeset applies):

```bash
make migrate
```

Run only changesets matching a specific label:

```bash
make migrate LABELS=release-1
```

Check pending changesets (optionally filtered by label):

```bash
make status
make status LABELS=release-2
```

Show migration history:

```bash
make history
```

Connect to PostgreSQL:

```bash
make psql
```

Stop containers:

```bash
make stop
```

Stop and remove data volume:

```bash
make clean
```

## Changelog labels

| Label | Changesets |
|---|---|
| *(none)* | schema + core tables, routines (function & procedure), `deployment_notes` |
| `release-1` | sequences, indexes, seed data |
| `release-2` | `release2_audit_events` table |

## Deploying individual releases

### Deploy only shared infrastructure (no label filter)

```bash
make start
make migrate
```

What runs:
- `001` — creates schema `lab` and tables `labels`, `work_items`, `work_item_labels`
- `004` — creates `fn_label_count_for_item` function and `sp_apply_label_to_item` procedure
- `008` — creates `deployment_notes` table

Changesets `002`, `003`, `006` (`release-1`) and `007` (`release-2`) are **skipped** because they have labels that don't match.

Wait — `make migrate` without `LABELS` applies **all** changesets. See the next scenarios for filtered deploys.

---

### Scenario A — deploy Release 1 only

```bash
make migrate LABELS=release-1
```

What runs (first time on a clean DB):
- `001` — schema + core tables *(no label → always included)*
- `002` — sequences *(matches `release-1`)*
- `003` — indexes *(matches `release-1`)*
- `004` — routines *(no label → always included)*
- `006` — seed data *(matches `release-1`)*
- `008` — `deployment_notes` table *(no label → always included)*

**Skipped:** `007` (`release-2` audit events table) — not yet ready for this environment.

After this you can verify:

```sql
SELECT sequence_name FROM information_schema.sequences WHERE sequence_schema = 'lab';
SELECT * FROM lab.work_items;
SELECT lab.fn_label_count_for_item(1000);
```

---

### Scenario B — deploy Release 2 only (after Release 1 is already applied)

```bash
make migrate LABELS=release-2
```

What runs:
- Changesets `001`, `004`, `008` are already recorded in `DATABASECHANGELOG`, so Liquibase skips them.
- `002`, `003`, `006` carry label `release-1`, which doesn't match — **skipped**.
- `007` — creates `release2_audit_events` table *(matches `release-2`)* — **runs**.

After this you can verify:

```sql
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'lab' ORDER BY table_name;
-- release2_audit_events should now appear

INSERT INTO lab.release2_audit_events (work_item_id, event_type)
VALUES (1000, 'STATUS_CHANGE');
SELECT * FROM lab.release2_audit_events;
```

---

### Scenario C — deploy everything at once

```bash
make migrate
```

All eight changesets run in order. Use this for a fresh environment (e.g. CI, local dev) where you want the full schema with no restrictions.

## Quick verification queries

Inside psql (`make psql`):

```sql
SELECT * FROM lab.work_items;
SELECT * FROM lab.labels;
SELECT * FROM lab.work_item_labels;
SELECT lab.fn_label_count_for_item(1000);
CALL lab.sp_apply_label_to_item(1000, 'qa');
```
