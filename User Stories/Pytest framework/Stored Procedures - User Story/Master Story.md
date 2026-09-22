# Stored Procedures Master Story

## Description

The purpose of this master story is to implement a part of the pytest framework that validates the behaviour of the stored procedures from Process Execution Tracking Database.

The framework ensures that stored procedures handle both valid inputs and error scenarios correctly, and that transactional integrity is maintained after any database change.

The framework will also be integrated into CI/CD so that automated tests can be executed consistently and regression issues can be identified early.

## User story

**As** a developer

**I want** an automatic testing framework that tests all stored procedures behaviour

**So that** I can ensure database integrity is maintained after any schema or procedure change without manual testing

## In Scope:

* Automated testing of stored procedures
* Happy path and error handling scenarios
* CI/CD integration

## Out of Scope:

* Testing the SQL scripts used to initially populate the database
* Testing the automations
* Bi Dashboard testing
* End-to-end application testing outside the database layer

## Acceptance criteria

* All stored procedures have at least one automated test
* Both happy path and error handling scenarios are covered
* Tests are executable with a single command (pytest)

## Testing & Development Principles

* Acceptance criteria are the source of truth for expected behaviour.
* Every stored procedure must have automated tests covering its relevant happy path and error scenarios.
* Tests should validate both the procedure response and the resulting database state where applicable.
* A failing test must be analysed before deciding whether the issue is in the stored procedure, the test, or the test data/setup.
* When the stored procedure does not satisfy the expected behaviour, development changes should be made to the procedure rather than weakening the test.
* Automated tests should provide repeatable feedback after each development change.

## Business Requirements

The Process Execution Tracking Database is responsible for storing and managing process execution data. Stored procedures represent an important part of the database business logic and are responsible for operations such as creating processes, managing users, starting executions, completing executions, handling failures, and cancelling executions.

Changes to stored procedures can directly affect the integrity and reliability of the execution tracking data.

The business therefore requires an automated and repeatable way to:

* Verify that stored procedures behave according to the defined requirements.
* Detect incorrect behaviour introduced by database changes.
* Prevent regressions when existing functionality is modified.
* Ensure that invalid operations do not result in unintended database changes.
* Provide confidence that critical database operations remain consistent over time.
* Reduce reliance on manual database testing.
* Provide fast feedback to developers during database changes.
* Establish a foundation for a test-driven development process for database logic.

## User stories links:

|US Number | User Story                                                                                      | Story Status| Development status|
| :---| :---                                                                                                 | :---        | :--               |
|US-01| [AddProcess](<User stories stored procedures/User Story - AddProcess.md>)                            | Done | In progress |  
|US-02| [ChangeName](<User stories stored procedures/User Story - ChangeName.md>)                            | Done | In progress |  
|US-03| [CorrectProcessName](<User stories stored procedures/User Story - CorrectProcessName.md>)            | Done | In progress |  
|US-04| [DeleteUser](<User stories stored procedures/User Story - DeleteUser.md>)                            | Done | In progress |  
|US-05| [StartExecution](<User stories stored procedures/User Story - StartExecution.md>)                    | Done | In progress |  
|US-06| [CompleteExecutionSuccess](<User stories stored procedures/User Story - CompelteExecutionSuccess.md>)| Done | In progress |  
|US-07| [CompleteExectionFailure](<User stories stored procedures/User Story - CompleteExecutionFailure.md>) | Done | In progress |  
|US-08| [CancelExecution](<User stories stored procedures/User Story - CancelExecution.md>)                  | Done | In progress |  
|US-09| [CI/CD](<User stories stored procedures/User Story - CI CD.md>)                                      | Done | In progress |   

[← Back](../Epic_story.md)
