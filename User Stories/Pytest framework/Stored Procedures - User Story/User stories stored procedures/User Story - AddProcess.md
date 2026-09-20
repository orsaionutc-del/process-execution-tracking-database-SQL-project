# US-01 AddProcess Automatic testing with PyTest

## Metadata & Estimation
* **Epic / Master Story:** Master Stored Procedures
* **Story Points:** 2 SP
* **Status:** In Progress

## User story

**As** a developer

**I want** an automatic test that tests AddProcess stored procedure

**So that** I can ensure database integrity is maintained after any schema or procedure change without manual testing

## In Scope

* Automated testing of AddProcess
* Happy path and error handling scenarios
* Database should remain in the initial state

## Out of Scope

* Improvment of stored procedures

## Technical scifications

* SQL component: AddProcess(IN param_process_name VARCHAR(100)) stored procedure that impacts PROCESSES table
* Target Pytest file: `tests/test_AddProcess.py`
* Validation rules:
    * `param_process_name` should NOT be NULL
    * `param_process_name` should NOT be an empty string
    * `param_process_name` should NOT be already present in `PROCESSES` table 
    * `param_process_name` should be succesfuly inserted in `PROCESSES` table if it respects all the rules from above

## Acceptance criteria

### AC-01 - NOT NULL error handling

* **Given** invalid parameter - NULL parameter
* **When** the procedure `AddProcess(NULL)` is called
* **Then** then the procedure returns `SQLSTATE '45000'`
* **And** the message text contains `'Please do not insert a NULL value'`

### AC-02 - empty string error handling

* **Given** invalid parameter - ' ' parameter
* **When** the procedure `AddProcess(' ')` is called
* **Then** then the procedure returns `SQLSTATE '45000'`
* **And** the message text contains `'This is an empty value'`

### AC-03 - name is not unique error handling

* **Given** a parameter `param_process_name` that already exists in `PROCESSES` table
* **When** the procedure `AddProcess(param_process_name)` is called
* **Then** then the procedure returns `SQLSTATE '45000'`
* **And** the message text contains `'You already have this process in the database'`

### AC-04 - happy path

* **Given** a valid parameter `param_process_name`
* **When** the procedure `AddProcess(param_process_name)` is called
* **Then** a record with process_name = param_process_name is found in the PROCESSES table

### AC-05 - no values from the database are changed trough the tests
* **Given** all the tests
* **When** the tests are called
* **Then** all changes that are made through the tests are rolled back

## Definition of done checklist

- [ ] All 4 testing scenarios have dedicated PyTest functions in `tests/test_AddProcess.py`.
- [ ] Database fixture incorporates automatic `conn.rollback()` cleanup.
- [ ] No database connection passwords or secrets are hardcoded.

[← Back](../Master Story.md)
