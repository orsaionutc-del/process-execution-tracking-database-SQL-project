# US-03 CorrectProcessName Automatic testing with Pytest

## Metadata & Estimation
* **Epic / Master Story:** Master Stored Procedures
* **Story Points:** 2 SP
* **Status:** In Progress

## User story

**As** a developer

**I want** an automatic test that tests CorrectProcessName stored procedure

**So that** I can ensure that process names are corrected according to the defined business rules without introducing duplicate process names

## In Scope

* Automated testing of CorrectProcessName
* Happy path and error handling scenarios
* Database should remain in the initial state

## Out of Scope

* Improvement of stored procedures

## Technical specifications

* SQL component: `CorrectProcessName(IN wrong_name VARCHAR(100), IN correct_name VARCHAR(100))` stored procedure that impacts the `PROCESSES` table
* Target Pytest file: `tests/test_CorrectProcessName.py`
* Validation rules:
    * `wrong_name` should identify an existing process in the `PROCESSES` table
    * `correct_name` should not already exist in the `PROCESSES` table
    * `wrong_name` and `correct_name` should not have the same value
    * A valid request should update the process name in the `PROCESSES` table

## Acceptance criteria

### AC-01 - Correct name already exists

* **Given** a `correct_name` that already exists in the `PROCESSES` table
* **When** the procedure `CorrectProcessName(wrong_name, correct_name)` is called
* **Then** the procedure returns `SQLSTATE '45000'`
* **And** the message text contains `'This name already exists in DB'`
* **And** the process name is not changed

### AC-02 - Wrong name and correct name are identical

* **Given** `wrong_name` and `correct_name` have the same value
* **When** the procedure `CorrectProcessName(wrong_name, correct_name)` is called
* **Then** the procedure returns `SQLSTATE '45000'`
* **And** the message text contains `'Be careful, maybe you made a typo. You introduced the same name.'`
* **And** the process name is not changed

### AC-03 - Wrong name does not exist

* **Given** a `wrong_name` that does not exist in the `PROCESSES` table
* **When** the procedure `CorrectProcessName(wrong_name, correct_name)` is called
* **Then** the procedure returns `SQLSTATE '45000'`
* **And** the message text contains `'No changes were made. We could not find the row that you want to update.'`
* **And** no process is changed

### AC-04 - Happy path

* **Given** a `wrong_name` that exists in the `PROCESSES` table
* **And** a `correct_name` that does not exist in the `PROCESSES` table
* **And** `wrong_name` and `correct_name` are different
* **When** the procedure `CorrectProcessName(wrong_name, correct_name)` is called
* **Then** the process with `wrong_name` is updated to `correct_name`
* **And** the old process name no longer exists in the `PROCESSES` table

### AC-05 - no values from the database are changed through the tests

* **Given** all the tests
* **When** the tests are called
* **Then** all changes that are made through the tests are rolled back

## Definition of done checklist

- [ ] All 4 testing scenarios have dedicated PyTest functions in `tests/test_CorrectProcessName.py`.
- [ ] Tests validate both SQLSTATE and expected error messages.
- [ ] Tests validate the resulting database state for the happy path.
- [ ] Database fixture incorporates automatic `conn.rollback()` cleanup.
- [ ] No database connection passwords or secrets are hardcoded.

[← Back](../Master%20Story.md)
