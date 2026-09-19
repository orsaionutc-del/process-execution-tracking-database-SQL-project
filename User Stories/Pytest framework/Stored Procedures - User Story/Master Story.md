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

## User stories links:

| User Story                                                              | Status      |
| :---                                                                    | :---        |
| [AddProcess](%User%stories%stored%procedures/User Story - AddProcess.md)| In progress |
| [ChangeName]                                                            | In progress |
| [CorrectProcessName]                                                    | In progress |
| [DeleteUser]                                                            | In progress |
| [StartExecution]                                                        | In progress |
| [CompleteExecutionSuccess]                                              | In progress |
| [CompleteExectionFailure]                                               | In progress |
| [CancelExecution]                                                       | In progress |
| [CI/CD]                                                                 | In progress |   
