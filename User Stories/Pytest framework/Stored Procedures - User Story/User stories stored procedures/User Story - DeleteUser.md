# US-04 DeleteUser Automatic testing with Pytest

## Metadata & Estimation
* **Epic / Master Story:** Master Stored Procedures
* **Story Points:** 2 SP
* **Status:** In Progress

## User story

**As** a developer

**I want** an automatic test that tests DeleteUser stored procedure

**So that** I can ensure that users are deleted according to the defined rules without introducing unintended changes to the database

## In Scope

* Automated testing of DeleteUser
* Happy path and error handling scenarios
* Database should remain in the initial state

## Out of Scope

* Improvement of stored procedures

## Technical specifications

* SQL component: `DeleteUser(IN param_fn VARCHAR(20), IN param_ln VARCHAR(20))` stored procedure that impacts the `USERS` table
* Target Pytest file: `tests/test_DeleteUser.py`
* Validation rules:
    * `param_fn` and `param_ln` should NOT be NULL
    * `param_fn` and `param_ln` should NOT be empty values
    * The user identified by `param_fn` and `param_ln` should exist in the `USERS` table
    * The user should be marked as deleted when the procedure is executed successfully
    * No unintended user data should be modified when the procedure returns an error

## Acceptance criteria

### AC-01 - NOT NULL error handling

* **Given** invalid parameters - NULL parameters
* **When** the procedure `DeleteUser(NULL, NULL)` is called
* **Then** the procedure returns `SQLSTATE '45000'`
* **And** the database state remains unchanged

### AC-02 - empty value error handling

* **Given** invalid parameters - empty parameters
* **When** the procedure `DeleteUser('', '')` is called
* **Then** the procedure returns `SQLSTATE '45000'`
* **And** the database state remains unchanged

### AC-03 - user does not exist error handling

* **Given** a first name and last name that do not identify an existing user
* **When** the procedure `DeleteUser(param_fn, param_ln)` is called
* **Then** the procedure returns `SQLSTATE '45000'`
* **And** no user is modified

### AC-04 - happy path

* **Given** an existing user identified by `param_fn` and `param_ln`
* **When** the procedure `DeleteUser(param_fn, param_ln)` is called
* **Then** the user's `deleted` value is changed to `TRUE`
* **And** the user's other stored information remains unchanged

### AC-05 - no values from the database are changed through the tests

* **Given** all the tests
* **When** the tests are called
* **Then** all changes that are made through the tests are rolled back

## Definition of done checklist

- [ ] All 4 testing scenarios have dedicated PyTest functions in `tests/test_DeleteUser.py`.
- [ ] Database fixture incorporates automatic `conn.rollback()` cleanup.
- [ ] No database connection passwords or secrets are hardcoded.

[← Back](../Master%20Story.md)
