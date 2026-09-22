# US-07 CompleteExecutionFailure Automatic testing with Pytest

## Metadata & Estimation
* **Epic / Master Story:** Master Stored Procedures
* **Story Points:** 3 SP
* **Status:** In Progress

## User story

**As** a developer

**I want** an automatic test that tests CompleteExecutionFailure stored procedure

**So that** I can ensure that a running execution can be marked as failed and the corresponding error is stored correctly

## In Scope

* Automated testing of CompleteExecutionFailure
* Happy path and error handling scenarios
* Validation of execution status and error data
* Database should remain in the initial state

## Out of Scope

* Improvement of stored procedures

## Technical specifications

* SQL component: `CompleteExecutionFailure(IN param_execution_id INT, IN param_error_msg VARCHAR(400))` stored procedure that impacts the `EXECUTIONS` and `ERRORS` tables
* Target Pytest file: `tests/test_CompleteExecutionFailure.py`
* Validation rules:
    * `param_execution_id` should identify an existing execution
    * The execution identified by `param_execution_id` must have status `RUNNING`
    * A valid running execution should be changed to status `FAILED`
    * An error record should be inserted for the failed execution
    * The stored error message should match `param_error_msg`
    * An execution that does not exist or is not currently running should not be modified

## Acceptance criteria

### AC-01 - execution does not exist

* **Given** a `param_execution_id` that does not exist in the `EXECUTIONS` table
* **When** the procedure `CompleteExecutionFailure(param_execution_id, param_error_msg)` is called
* **Then** the procedure returns `SQLSTATE '45000'`
* **And** the message text contains `'This execution does not exist or is not currently running.'`
* **And** no execution is modified
* **And** no error record is inserted

### AC-02 - execution is not currently running

* **Given** an existing execution whose status is different from `RUNNING`
* **When** the procedure `CompleteExecutionFailure(param_execution_id, param_error_msg)` is called
* **Then** the procedure returns `SQLSTATE '45000'`
* **And** the message text contains `'This execution does not exist or is not currently running.'`
* **And** the execution status remains unchanged
* **And** no error record is inserted

### AC-03 - happy path

* **Given** an existing execution with status `RUNNING`
* **And** a valid `param_error_msg`
* **When** the procedure `CompleteExecutionFailure(param_execution_id, param_error_msg)` is called
* **Then** the execution status is changed to `FAILED`
* **And** a record is inserted into the `ERRORS` table
* **And** the inserted error is associated with the correct `execution_id`
* **And** the stored error message matches `param_error_msg`

### AC-04 - execution and error are changed as one operation

* **Given** an existing execution with status `RUNNING`
* **When** an SQL exception occurs during the failure operation
* **Then** the transaction is rolled back
* **And** the execution is not left with a partially updated state
* **And** no unintended error record remains in the database

### AC-05 - no values from the database are changed through the tests

* **Given** all the tests
* **When** the tests are called
* **Then** all changes that are made through the tests are rolled back

## Definition of done checklist

- [ ] All 4 testing scenarios have dedicated PyTest functions in `tests/test_CompleteExecutionFailure.py`.
- [ ] Tests validate the expected SQLSTATE and error message.
- [ ] Tests validate the resulting `EXECUTIONS` and `ERRORS` records.
- [ ] Database fixture incorporates automatic `conn.rollback()` cleanup.
- [ ] No database connection passwords or secrets are hardcoded.

[← Back](../Master%20Story.md)
