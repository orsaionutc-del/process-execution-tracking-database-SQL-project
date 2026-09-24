# Stored Procedures Master Story

## Description

The purpose of this Master Story is to define the automated validation required for the stored procedures within the Process Execution Tracking Database.

The validation ensures that stored procedures behave according to their expected requirements, handle valid and invalid scenarios correctly, and maintain database consistency after successful or failed operations.

## Expected Outcome

All in-scope stored procedures have repeatable automated validation covering their relevant functional and error scenarios.

The automated tests provide evidence that changes to stored procedures do not introduce unintended behaviour or regressions.

## Scope

The following stored procedures are included in this Master Story.

- `AddProcess`
- `CorrectProcessName`
- `ChangeName`
- `DeleteUser`
- `StartExecution`
- `CompleteExecutionSuccess`
- `CompleteExecutionFailure`
- `CancelExecution`

### Testing Scope

The automated testing scope includes, where applicable:

- Successful execution scenarios
- Invalid input scenarios
- Error handling
- Business rule validation
- Expected database state after successful operations
- Database state after failed operations
- Transactional integrity
- Regression validation

---

## Out of Scope

The following are outside the scope of this Master Story:

- Testing of database views
- Testing of tables and their structure or behaviour
- Testing of database constraints as separate database components
- Testing of SQL scripts used to initially populate the database
- Testing of RPA/Automation processes
- BI dashboard testing
- End-to-end application testing outside the database layer
- CI/CD implementation

These areas are addressed separately within the **Python automated testing framework** initiative.

## Requirement Traceability

This Master Story provides coverage for the Initiative requirements relevant to automated validation of stored procedures.

| Initiative Requirement | Covered by this Master Story | Related User Stories |
| :--- | :--- | :--- |
| **GBR-01 — Database Behaviour Validation** | Validate expected stored procedure behaviour | US-01–US-08 |
| **GBR-02 — Data Integrity** | Validate database state after stored procedure execution | US-01–US-08 |
| **GBR-03 — Business Rule Validation** | Validate business rules enforced by stored procedures | US-01–US-08 |
| **GBR-04 — Regression Prevention** | Provide automated regression coverage for stored procedures | US-01–US-08 |
| **GBR-05 — Error Handling** | Validate invalid inputs and stored procedure error scenarios | US-01–US-08 |
| **GBR-06 — Transactional Integrity** | Validate database consistency after failed operations | US-04–US-08 |
| **GBR-07 — Database Component Coverage** | Provide automated coverage for the stored procedure component | US-01–US-08 |
| **GBR-08 — Repeatable Testing** | Execute stored procedure validation repeatedly using pytest | US-01–US-08 |
| **GBR-09 — Change Validation** | Validate stored procedure changes before merge | US-01–US-08 |
| **GBR-10 — CI/CD Integration** | Make stored procedure tests executable within the CI/CD process | US-01–US-08 |

Detailed Acceptance Criteria are defined within each User Story and are validated through the corresponding automated pytest tests.

## User stories links:

|US Number | User Story                                                                                      | Story Status| Development status|
| :---| :---                                                                                                 | :---        | :--               |
|US-01| [AddProcess](<User stories stored procedures/User Story - AddProcess.md>)                            | Done | In progress |  
|US-02| [ChangeName](<User stories stored procedures/User Story - ChangeName.md>)                            | Done | In progress |  
|US-03| [CorrectProcessName](<User stories stored procedures/User Story - CorrectProcessName.md>)            | Done | In progress |  
|US-04| [DeleteUser](<User stories stored procedures/User Story - DeleteUser.md>)                            | Done | In progress |  
|US-05| [StartExecution](<User stories stored procedures/User Story - StartExecution.md>)                    | Done | In progress |  
|US-06| [CompleteExecutionSuccess](<User stories stored procedures/User Story - CompleteExecutionSuccess.md>)| Done | In progress |  
|US-07| [CompleteExectionFailure](<User stories stored procedures/User Story - CompleteExecutionFailure.md>) | Done | In progress |  
|US-08| [CancelExecution](<User stories stored procedures/User Story - CancelExecution.md>)                  | Done | In progress |

## Definition of Done

This Master Story is complete when:

- All eight stored procedures have corresponding User Stories.
- Each User Story has defined and testable Acceptance Criteria.
- Relevant Acceptance Criteria have corresponding automated pytest tests.
- Relevant successful and error scenarios are covered.
- Applicable business rules are validated.
- Expected database state is validated after successful operations.

### Traceability Flow

**Initiative Requirement → Master Story → User Story → Acceptance Criteria → Automated Test**

[← Back](../Initiative.md)