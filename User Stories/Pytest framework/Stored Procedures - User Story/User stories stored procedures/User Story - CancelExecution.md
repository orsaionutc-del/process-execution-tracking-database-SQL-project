# US-08 CancelExecution Automatic testing with Pytest

## Metadata & Estimation
* **Epic / Master Story:** Master Stored Procedures
* **Story Points:** 2 SP
* **Status:** In Progress

## User story

**As** a developer

**I want** an automatic test that tests CancelExecution stored procedure

**So that** I can ensure that only running executions can be cancelled

## In Scope

* Automated testing of CancelExecution
* Happy path and error handling scenarios
* Validation of execution status
* Database should remain in the initial state

## Out of Scope

* Improvement of stored procedures

## Technical specifications

* SQL component: `CancelExecution(IN p_execution_id INT)` stored procedure that impacts the `EXECUTIONS` table
* Target Pytest file: `tests/test_CancelExecution.py`
* Validation rules:
    * `p_execution_id` should NOT be NULL
    * `p_execution_id` should identify an existing execution
    * The execution identified by `p_execution_id` must have status `RUNNING`
    * A valid running execution should be changed to status `CANCELLED`
    * An execution that does not exist or is not currently running should not be modified

## Acceptance criteria

### AC-01 - NULL execution ID

* **Given** a NULL `p_execution_id`
* **When** the procedure `CancelExecution(NULL)` is called
* **Then** the procedure returns `SQLSTATE '45000'`
* **And** the message text contains `'Provide a value that is not null.'`
* **And** no execution is modified

### AC-02 - execution does not exist

* **Given** a `p_execution_id` that does not exist in the `EXECUTIONS` table
* **When** the procedure `CancelExecution(p_execution_id)` is called
* **Then** the procedure returns `SQLSTATE '45000'`
* **And** the message text contains `'Execution does not exist or status is not RUNNING'`
* **And** no execution is modified

### AC-03 - execution is not currently running

* **Given** an existing execution whose status is different from `RUNNING`
* **When** the procedure `CancelExecution(p_execution_id)` is called
* **Then** the procedure returns `SQLSTATE '45000'`
* **And** the message text contains `'Execution does not exist or status is not RUNNING'`
* **And** the execution status remains unchanged

### AC-04 - happy path

* **Given** an existing execution with status `RUNNING`
* **When** the procedure `CancelExecution(p_execution_id)` is called
* **Then** the execution status is changed to `CANCELLED`
* **And** no other execution record is modified

### AC-05 - no values from the database are changed through the tests

* **Given** all the tests
* **When** the tests are called
* **Then** all changes that are made through the tests are rolled back

## Definition of done checklist

- [ ] All 4 testing scenarios have dedicated PyTest functions in `tests/test_CancelExecution.py`.
- [ ] Tests validate the expected SQLSTATE and error message.
- [ ] Tests validate the resulting `EXECUTIONS` database state.
- [ ] Database fixture incorporates automatic `conn.rollback()` cleanup.
- [ ] No database connection passwords or secrets are hardcoded.

[← Back](../Master%20Story.md)
