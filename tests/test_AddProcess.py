import mysql.connector
import pytest


def test_add_process_rejects_null(db_cursor):
    with pytest.raises(
        mysql.connector.Error,
        match="Plecd
        Please do not insert a NULL value"
    ):
        db_cursor.callproc("AddProcess", (None,))