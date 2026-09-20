# Epic Story - Python automated testing framework

## Description

The purpose of this epic is to implement an automated pytest testing framework that validates the behavior of Process Execution Tracking Database.

The framework ensures that stored procedures, views, constraints and tables handle both valid inputs and error scenarios correctly, and that transactional integrity is maintained after any database change.

The framework will also be integrated into CI/CD so that automated tests can be executed consistently and regression issues can be identified early.

## User Story

**As** a Developer

**I want** an automated testing framework that validates stored procedures, views, constraints and tables behaviour

**So that** I can ensure database integrity is maintained after any schema or procedure change without manual testing

## In Scope:

* Automated testing of stored procedures
* Automated validation of tables and their expected structure/behavior
* Automated testing of views
* Automated testing of database constraints
* Happy path and error handling scenarios
* CI/CD integration

## Out of Scope:

* Testing the SQL scripts used to initially populate the database
* Testing the automations
* Bi Dashboard testing
* End-to-end application testing outside the database layer

## Acceptance criteria

* All stored procedures have at least one automated test
* All tables have at least one automated test
* All views have at least one automated test
* All constraints have at least one automated test
* Both happy path and error handling scenarios are covered
* Tests are executable with a single command (pytest)
* Test results are visible and interpretable without additional tooling

## Master stories links:

| Master Story                                                                              | Status      |
| :---                                                                                      | :---        |
| [Stored Procedures](Stored%20Procedures%20-%20User%20Story/Master%20Story.md)             | In progress |
| Views                                                                                     | Not started |
| Tables                                                                                    | Not started |
| Constraints                                                                               | Not started |
| CI/CD                                                                                     | In progress |     

[← Back](../../README.md)
