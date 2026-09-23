import os

import mysql.connector
import pytest


@pytest.fixture
def db_connection():
    connection = mysql.connector.connect(
        host=os.getenv("DB_HOST", "127.0.0.1"),
        port=int(os.getenv("DB_PORT", "3306")),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD", ""),
        database=os.getenv("DB_NAME", "process_execution_tracking"),
    )

    yield connection

    if connection.is_connected():
        connection.close()


@pytest.fixture
def db_cursor(db_connection):
    cursor = db_connection.cursor()

    yield cursor

    cursor.close()