# US-02 ChangeName Automatic testing with Pytest

## Metadata & Estimation
* **Epic / Master Story:** Master Stored Procedures
* **Story Points:** 2 SP
* **Status:** In Progress

## User story

**As** a developer

**I want** an automatic test that tests ChangeName stored procedure

**So that** I can ensure database integrity is maintained after any schema or procedure change without manual testing

## In Scope

* Automated testing of ChangeName
* Happy path and error handling scenarios
* Database should remain in the initial state

## Out of Scope

* Improvement of stored procedures

## Technical specifications

* SQL component: ChangeName(IN param_fn VARCHAR(20),IN param_ln VARCHAR(20),IN par_id SMALLINT) stored procedure that impacts USERS table
* Target Pytest file: `tests/test_ChangeName.py`
* Validation rules:
    * `param_fn`, `param_ln`, `par_id` should NOT be NULL
    * `param_fn`, `param_ln`, `par_id`  should NOT be an empty string
    * `param_fn`, `param_ln`, `par_id`  should NOT be already present in `USERS` table 
    * `param_fn`, `param_ln`, `par_id`  should succesfuly update the row with `par_id` in `PROCESSES` table if it respects all the rules from above

## Acceptance criteria

### AC-01 - NOT NULL error handling

* **Given** invalid parameters - NULL parameters
* **When** the procedure `ChangeName(NULL)` is called
* **Then** then the procedure returns `SQLSTATE '45000'`
* **And** the message text contains `'Please do not insert a NULL values'`

### AC-02 - empty string error handling

* **Given** invalid parameters - ' ' parameters
* **When** the procedure `ChangeName(' ')` is called
* **Then** then the procedure returns `SQLSTATE '45000'`
* **And** the message text contains `'This is an empty value'`

### AC-03 - CONCAT(param_fn,' ',param_ln) is not unique error handling

* **Given** CONCAT(param_fn,' ',param_ln) that already exists in `PROCESSES` table
* **When** the procedure `ChangeName(param_fn, param_ln, par_id)` is called
* **Then** then the procedure returns `SQLSTATE '45000'`
* **And** the message text contains `'You already have this user in the database'`

### AC-04

* **Given** a user ID that does not exist
* **When** ChangeName('John', 'Smith', 9999) is called
* **Then** then the procedure returns `SQLSTATE '45000'
* **And** the message text contains `'You already have this user in the database'`

### AC-05 - happy path

* **Given** valid parameters `param_fn`, `param_ln`, `par_id`
* **When** the procedure `ChangeName(param_fn, param_ln, par_id)` is called
* **Then** a record with param_fn, param_ln, par_id is found in the USERS table
* **And** the old record is updated

### AC-06 - no values from the database are changed trough the tests
* **Given** all the tests
* **When** the tests are called
* **Then** all changes that are made through the tests are rolled back

## Definition of done checklist

- [ ] All 4 testing scenarios have dedicated PyTest functions in `tests/test_ChangeName.py`.
- [ ] Database fixture incorporates automatic `conn.rollback()` cleanup.
- [ ] No database connection passwords or secrets are hardcoded.

[← Back](../Master%20Story.md)
