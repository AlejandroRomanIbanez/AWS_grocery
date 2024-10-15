# Migrating from SQLite3 to PostgreSQL

This tutorial will guide you through the process of migrating your SQLite3 database to PostgreSQL. We assume you already have an RDS instance configured and ready for use.

---

## Steps Overview

1. Export SQLite3 Database
2. Modify the Dump File
3. Connect to PostgreSQL RDS
4. Initialize Flask with PostgreSQL
5. Load Data into PostgreSQL
6. Update Flask Configuration

---

### Step 1: Export SQLite3 Database

To export your SQLite3 database, run the following command in the `/app` directory:

```bash
sqlite3 local.db .dump > sqlite_dump.sql
```

This will create a SQL dump of your SQLite3 database.

---

### Step 2: Modify the Dump File

You’ll need to adjust the dump file to ensure compatibility with PostgreSQL. Here’s what to modify:

- Remove PRAGMA Statements: PostgreSQL does not support these, so you can safely delete them.
  
- Convert AUTOINCREMENT to SERIAL:  
  In PostgreSQL, use SERIAL for auto-incrementing columns. Change lines like this:

    id INTEGER PRIMARY KEY AUTOINCREMENT

  To:

    id SERIAL PRIMARY KEY

- Check Data Types: Ensure the data types are compatible with PostgreSQL. Common types like TEXT, INTEGER, and TIMESTAMP should be fine, but double-check any custom types.

- Remove Transaction Wrappers: PostgreSQL doesn't need `BEGIN TRANSACTION;` or `COMMIT;` lines, so remove them.

- Remove sqlite_sequence: This is SQLite-specific and can be removed.

- Convert Boolean Values: PostgreSQL expects TRUE/FALSE instead of 0/1.

---

### Step 3: Initialize Flask with PostgreSQL

Ensure your Flask application’s migrations are in sync with the PostgreSQL database schema. Run the following commands:
```bash
flask db init
flask db migrate -m "Initial migration"
flask db upgrade
```
This will set up the tables in PostgreSQL based on your Flask models.

If you have some issues with the transition from sqlite to PostgreSQL, you can use the file provided in this commit called sqlite_dump_clean.sql directly

---

### Step 4: Connect to PostgreSQL RDS

Once you’ve made the necessary changes, connect to your PostgreSQL RDS instance. Use a command like this:

```bash
psql -h grocery.ct8k8ea26mxp.eu-central-1.rds.amazonaws.com -U postgres -d grocerydb
```


Replace the host, username, and database name with your own values.

---

### Step 5: Load Data into PostgreSQL

To load the modified SQLite dump into PostgreSQL, run this command from within `psql`:

\i path_to_sqlite_dump.sql

This will execute the dump file and populate your PostgreSQL database with the data from SQLite.

---

### Step 6: Update Flask Configuration

Update your Flask configuration to point to PostgreSQL. In your `.env` file, update the `SQLALCHEMY_DATABASE_URI` to use the PostgreSQL RDS connection string.

You can test it first locally and then implement it in your EC2 instance, remember to restart the app in the EC2 machine to see the changes
You can use Pgadmin4 to visualize the data of your RDS to test if is connected properly

Example:

FLASK_ENV=environment
POSTGRES_URI=postgresql://<username>:<password>@<rds-endpoint>:<rds-port>/<rds-database>

Replace `<username>` and `<password>`, `<rds-endpoint>`, `<rds-port>` and `<rds-database>` with your actual credentials.
