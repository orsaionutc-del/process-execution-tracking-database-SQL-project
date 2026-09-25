---
name: User Story
about: User story with acceptance criteria, tehnical specifications and definition of done
labels: user-story
---

# US-[XX] [Procedure Name] Automatic testing with PyTest

## Metadata & Estimation
* **Epic / Master Story:** 
* **Story Points:**
* **Status:**

## User Story

**As** a developer
**I want** an automatic test that tests [procedure name] stored procedure
**So that** I can ensure database integrity is maintained after any schema or procedure change without manual testing

## Acceptance Criteria

### AC-01 - 

* **Given** 
* **When** 
* **Then** 
* **And** 

### AC-02 - 

* **Given** 
* **When** 
* **Then** 
* **And** 

### AC-03 - 

* **Given** 
* **When** 
* **Then** 
* **And** 

### AC-04 - happy path

* **Given** 
* **When** 
* **Then** 

### AC-05 - no values from the database are changed through the tests

* **Given** all the tests
* **When** the tests are called
* **Then** all changes that are made through the tests are rolled back

## Definition of Done

- [ ] All testing scenarios have dedicated PyTest functions in `tests/test_[ProcedureName].py`
- [ ] Tests validate expected SQLSTATE and error messages where applicable
- [ ] Tests validate resulting database state
- [ ] No database connection passwords or secrets are hardcoded
- [ ] All tests pass in CI/CD pipeline

[← Back]()