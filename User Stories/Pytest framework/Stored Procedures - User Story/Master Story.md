# Stored Procedures Master Story

## Description

The purpose of this Master Story is to define the automated validation required for the stored procedures within the Process Execution Tracking Database.

The validation ensures that stored procedures behave according to their expected requirements, handle valid and invalid scenarios correctly, and maintain database consistency after successful or failed operations.

## Expected Outcome

All in-scope stored procedures have repeatable automated validation covering their relevant functional and error scenarios.

The automated tests provide evidence that changes to stored procedures do not introduce unintended behaviour or regressions.

## Scope

This Master Story covers the automated validation of stored procedures responsible for:

- Process management
- User management
- Process execution lifecycle

## Acceptance Criteria

- All in-scope stored procedures have automated tests.
- Relevant happy-path scenarios are covered.
- Relevant error and invalid-input scenarios are covered.
- Tests validate the expected database state where applicable.
- Failed operations do not leave unintended database changes.
- Tests can be executed consistently using pytest.
- The test suite provides repeatable feedback after database changes.

## Requirement Coverage

| Initiative Requirement | Application to Stored Procedures |
| :--- | :--- |
| GBR-01 | Validate expected stored procedure behaviour |
| GBR-02 | Verify database consistency after execution |
| GBR-03 | Validate business rules enforced by procedures |
| GBR-04 | Detect regressions in existing procedures |
| GBR-05 | Validate error and invalid-input scenarios |
| GBR-06 | Verify transactional integrity |
| GBR-08 | Ensure repeatable test execution |
| GBR-09 | Validate relevant changes before merge |

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

[← Back](../Initiative.md)
