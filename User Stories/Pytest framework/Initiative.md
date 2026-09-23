# Initiative - Python automated testing framework

## Description

The purpose of this initiative is to implement an automated pytest testing framework that validates the behavior of Process Execution Tracking Database.

The framework ensures that stored procedures, views, constraints and tables handle both valid inputs and error scenarios correctly, and that transactional integrity is maintained after any database change.

The framework will also be integrated into CI/CD so that automated tests can be executed consistently and regression issues can be identified early.

## Business Problem:

Future modifications to the database may unintentionally affect data integrity, business rules or the consistency of existing functionality.

As the project is expected to have multiple contributors, a standardised automated testing framework is required before accepting changes through the pull request process.

Automated database testing will allow contributors to validate changes faster and consistently, while reducing the risk of regressions.

The Process Execution Tracking Database provides information used by the Automation/RPA and BI teams to monitor and analyse automated processes. Database defects could therefore affect the reliability of business insights and potentially impact automations that rely on the database, particularly during critical business periods such as month-end closing.

## Business Objectives:

* Establish a standardised approach for validating changes to the database.
* Automatically validate database functionality affected by development changes.
* Detect regressions before changes are merged into the main branch.
* Improve confidence in the consistency and integrity of the database.
* Reduce the effort required for repetitive manual database validation.
* Establish automated testing as part of the database development lifecycle.

## In Scope:

* Automated testing of stored procedures
* Automated validation of tables and their expected structure/behavior
* Automated testing of views
* Automated testing of database constraints
* Happy path and error handling test scenarios
* CI/CD integration
* TDD Development

## Out of Scope:

* Testing the SQL scripts used to initially populate the database
* Testing the automations
* Bi Dashboard testing
* End-to-end application testing outside the database layer

## Stakeholders: 

* RPA/Automation Team
* Finance Team
* BI Team
* DBA Developers

## General Business Requirements

### GBR-01 — Database Behaviour Validation

The database shall be validated against its expected business and functional behaviour.

### GBR-02 — Data Integrity

The testing solution shall verify that database changes do not compromise data consistency or integrity.

### GBR-03 — Business Rule Validation

The testing solution shall verify that defined business rules are correctly enforced by the database.

### GBR-04 — Regression Prevention

Existing database functionality shall be automatically validated after relevant changes to reduce the risk of regressions.

### GBR-05 — Error Handling

The testing solution shall verify that the database handles invalid inputs and error scenarios according to the expected behaviour.

### GBR-06 — Transactional Integrity

The testing solution shall verify that database operations maintain transactional integrity and do not leave inconsistent data after failed operations.

### GBR-07 — Database Component Coverage

The automated testing approach shall provide validation across the relevant database components, including stored procedures, views, tables and constraints.

### GBR-08 — Repeatable Testing

Database tests shall be repeatable and provide consistent results when executed against the appropriate test environment.

### GBR-09 — Change Validation

Database changes shall be automatically validated before they are accepted into the main development branch.

### GBR-10 — CI/CD Integration

The automated test suite shall be integrated into the CI/CD process to provide automated validation of relevant database changes.

## Success Criteria

The initiative will be considered successful when:

* Critical database functionality is covered by automated tests.
* Relevant changes to the database can be validated automatically.
* Both expected and error scenarios are covered for relevant database functionality.
* Database consistency and transactional behaviour are automatically validated.
* Automated tests are executed as part of the CI/CD process.
* Test results are available as part of the pull request validation process.
* Existing functionality is protected against regressions when new changes are introduced.

## Master stories links:

| Master Story                                                                              | Status      |
| :---                                                                                      | :---        |
| [Stored Procedures](Stored%20Procedures%20-%20User%20Story/Master%20Story.md)             | In progress |
| Views                                                                                     | Not started |
| Tables                                                                                    | Not started |
| Constraints                                                                               | Not started |
| CI/CD                                                                                     | In progress |     

[← Back](../../README.md)
