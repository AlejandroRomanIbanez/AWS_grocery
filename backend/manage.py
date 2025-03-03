import os
import time
import psycopg2
from flask_migrate import Migrate, upgrade, init, migrate
from app import create_app, db, Config

app = create_app()
migration = Migrate(app, db)

POSTGRES_URI = os.getenv("POSTGRES_URI")
IS_RDS = Config.is_rds()
IS_LOCAL = not IS_RDS

MIGRATIONS_PATH = os.path.join(os.path.dirname(__file__), "migrations")


def wait_for_db():
    """Wait for PostgreSQL to be ready before starting migrations."""
    print("⏳ Waiting for database to be ready...")
    while True:
        try:
            conn = psycopg2.connect(POSTGRES_URI)
            conn.close()
            print("✅ Database is ready!")
            break
        except psycopg2.OperationalError:
            print("⚠️ Database is not ready yet. Retrying in 3 seconds...")
            time.sleep(3)


def run_migrations():
    """Run database migrations to ensure tables exist."""
    if IS_LOCAL:
        with app.app_context():
            if not os.path.exists(MIGRATIONS_PATH):
                print("⚠️ No migrations found. Initializing migrations...")
                init()

            versions_path = os.path.join(MIGRATIONS_PATH, "versions")
            if not os.path.exists(versions_path) or not os.listdir(versions_path):
                print("🔄 No migration files detected. Auto-generating initial migration...")
                migrate(message="Initial migration")

            print("🚀 Running database migrations...")
            upgrade()

    else:
        print("✅ Skipping migrations - Using AWS RDS")


def seed_database():
    """Seed the database, ensuring products are inserted before reviews."""
    if IS_LOCAL:
        sql_file = "app/sqlite_dump_clean.sql"
        if os.path.exists(sql_file) and IS_LOCAL:
            print("📂 Seeding database with sqlite_dump_clean.sql...")

            with app.app_context():
                conn = db.engine.raw_connection()
                cursor = conn.cursor()

                with open(sql_file, "r", encoding="utf-8") as f:
                    sql_commands = [cmd.strip() for cmd in f.read().split(";") if cmd.strip()]

                # 🛠️ Insert products first
                for command in sql_commands:
                    if "INSERT INTO products" in command:
                        try:
                            cursor.execute(command)
                        except psycopg2.errors.UniqueViolation:
                            # Suppress duplicate product entry messages
                            conn.rollback()
                        except psycopg2.Error as e:
                            print(f"❌ Critical SQL Error (Products): {e}")
                            conn.rollback()

                conn.commit()

                # 🛠️ Insert all other data (users, reviews, etc.)
                for command in sql_commands:
                    if "INSERT INTO products" not in command:
                        try:
                            cursor.execute(command)
                        except psycopg2.errors.ForeignKeyViolation:
                            conn.rollback()
                        except psycopg2.errors.UniqueViolation:
                            conn.rollback()
                        except psycopg2.errors.DuplicateTable:
                            conn.rollback()
                        except psycopg2.Error as e:
                            print(f"❌ Critical SQL Error: {e}")
                            conn.rollback()

                conn.commit()
                cursor.close()
                conn.close()

            print("✅ Database seeding complete!")


if __name__ == "__main__":
    wait_for_db()
    run_migrations()
    seed_database()
