# US-05 StartExecution Automatic testing with Pytest

## Metadata & Estimation
* **Epic / Master Story:** Master Stored Procedures
* **Story Points:** 3 SP
* **Status:** In Progress

## User story

**As** a developer

**I want** an automatic test that tests StartExecution stored procedure

**So that** I can ensure that a process execution can be started only with valid process and user data

## In Scope

* Automated testing of StartExecution
* Happy path and error handling scenarios
* Database should remain in the initial state

## Out of Scope

* Improvement of stored procedures

## Technical specifications

* SQL component: `StartExecution(IN par_user_id SMALLINT, IN par_process_id INTEGER, IN par_batch_id INTEGER)` stored procedure that impacts the `EXECUTIONS` table
* Target Pytest file: `tests/test_StartExecution.py`
* Validation rules:
    * `par_user_id` should identify an existing user in the `USERS` table
    * `par_process_id` should identify an existing process in the `PROCESSES` table
    * `par_batch_id` should identify an existing batch in the `BATCHES` table
    * A valid execution should be inserted into the `EXECUTIONS` table
    * A newly created execution should have the expected `RUNNING` status
    * Invalid input should not create an execution record

## Acceptance criteria

### AC-01 - invalid user error handling

* **Given** a `par_user_id` that does not exist in the `USERS` table
* **When** the procedure `StartExecution(par_user_id, par_process_id, par_batch_id)` is called
* **Then** the procedure returns `SQLSTATE '45000'`
* **And** no execution is created

### AC-02 - invalid process error handling

* **Given** a `par_process_id` that does not exist in the `PROCESSES` table
* **When** the procedure `StartExecution(par_user_id, par_process_id, par_batch_id)` is called
* **Then** the procedure returns `SQLSTATE '45000'`
* **And** no execution is created

### AC-03 - invalid batch error handling

* **Given** a `par_batch_id` that does not exist in the `BATCHES` table
* **When** the procedure `StartExecution(par_user_id, par_process_id, par_batch_id)` is called
* **Then** the procedure returns `SQLSTATE '45000'`
* **And** no execution is created

### AC-04 - happy path

* **Given** a valid user, process and batch
* **When** the procedure `StartExecution(par_user_id, par_process_id, par_batch_id)` is called
* **Then** a new record is created in the `EXECUTIONS` table
* **And** the record contains the provided user, process and batch IDs
* **And** the execution status is `RUNNING`

### AC-05 - no values from the database are changed through the tests

* **Given** all the tests
* **When** the tests are called
* **Then** all changes that are made through the tests are rolled back

## Definition of done checklist

- [ ] All 4 testing scenarios have dedicated PyTest functions in `tests/test_StartExecution.py`.
- [ ] Database fixture incorporates automatic `conn.rollback()` cleanup.
- [ ] No database connection passwords or secrets are hardcoded.

[← Back](../Master%20Story.md)
