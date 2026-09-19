# Process Execution Tracking Database

By Orsa Ionut Cristian

## Scope

The purpose of this database is to have an audit trail of the scripts and processes that are executed in an accounting environment.

### Which people, places, things, etc. are included in the scope of this database?

- Accounting department users that are using the scripts
- The input data from the ERP
- The output data that will be uploaded in the ERP
- The name and details of the scripts that were used
- An error/ process status table

### Which people, places, things, etc. are *outside* the scope of the database?

- Financial data stored inside the ERP
- Validation of accounting data correctness
- Business approval workflows


## Functional Requirements

When using a script that automates an ERP process the user should be able to have an audit trail.
This database is needed only for audit trail and error checking, the user should not use this data to check if the financial data from Accounting is correct. To check if the data is correct the user should look directly into the ERP.

Also, this database keeps track of process execution status. 

When a process is started a new batch id is inserted in the table BATCHES, the same batch id is inserted in table INPUTS along with the input file, and in the table EXECUTION our stored procedure inserts the specific process id, the id of the user that executes the script, the same batch id, and the status of the execution (RUNNING, SUCCESS or FAILED). After this, when the script is finished we have two other stored procedures that update the status of the process and save the outputs. These 2 stored procedures have error handling and transactions that provides data accuracy. Also, partial updates are rolled back if an error occurs.

## Representation

    USERS ||--o{ EXECUTIONS : runs
    USERS {
        SMALLINT user_id PK "AUTO_INCREMENT"
        VARCHAR(20) first_name "NOT NULL"
        VARCHAR(20) last_name "NOT NULL"
        DATETIME created_at "NOT NULL DEFAULT CURRENT_TIMESTAMP"
        BOOLEAN deleted "NOT NULL DEFAULT FALSE"
    }

    PROCESSES ||--o{ EXECUTIONS : executed
    PROCESSES {
        INTEGER process_id PK "AUTO_INCREMENT"
        VARCHAR(100) name "NOT NULL UNIQUE"
        BOOLEAN deleted "NOT NULL DEFAULT FALSE"
        DATETIME created_at "NOT NULL DEFAULT CURRENT_TIMESTAMP"
    }

    BATCHES ||--o{ EXECUTIONS : belongs_to
    EXECUTIONS {
        INTEGER execution_id PK "AUTO_INCREMENT"
        INTEGER process_id FK "NOT NULL"
        SMALLINT user_id FK "NOT NULL"
        INTEGER batch_id FK "NOT NULL"
        DATETIME executed_at "NOT NULL DEFAULT CURRENT_TIMESTAMP"
        ENUM status "NOT NULL"
    }


    BATCHES {
        INTEGER batch_id PK "AUTO_INCREMENT"
        DATETIME created_at "NOT NULL DEFAULT CURRENT_TIMESTAMP"
    }

    BATCHES ||--|| INPUTS : has
    INPUTS {
        INTEGER input_id PK "AUTO_INCREMENT NOT NULL"
        INTEGER batch_id FK "NOT NULL"
        MEDIUMBLOB input "NOT NULL"
    }

    EXECUTIONS ||--|| OUTPUTS : generates
    OUTPUTS {
        INTEGER output_id PK "AUTO_INCREMENT NOT NULL"
        INTEGER execution_id FK "NOT NULL"
        MEDIUMBLOB output "NOT NULL"
    }

    EXECUTIONS ||--o{ ERRORS : generates
    ERRORS {
        INTEGER error_id PK "AUTO_INCREMENT NOT NULL"
        INTEGER execution_id FK "NOT NULL"
        VARCHAR(400) error_msg "NOT NULL"

    }

### Entities

* Entities represented in the database:

Users, processes, executions, batches, inputs, outputs, and errors.

* The attributes of the entities are:

The entities use integer identifiers and foreign keys, VARCHAR fields for names and messages, BLOB fields for storing the original input and output files, BOOLEAN fields for process flags, and DATETIME fields for execution timestamps.

* Why did I choose the types I did?

The database uses integers for identifiers and foreign keys, VARCHAR fields for names and error messages, BLOB fields for storing the original Excel files used as inputs and outputs, BOOLEAN fields for logical flags, and DATETIME fields for recording execution timestamps.

* Why did I choose the constraints I did?

Primary key constraints are used to uniquely identify records in every table.
Foreign key constraints are used to enforce relationships between users, processes, executions, batches, inputs, outputs and errors.
The deleted attribute in the Processes table is represented as a Boolean value so that processes can be soft-deleted without losing historical execution data.
VARCHAR limits were chosen based on expected data sizes to avoid unnecessary storage usage while still providing sufficient flexibility.

### Relationships

![DatabaseDiagram](Diagram.jpg)


    USERS ||--o{ EXECUTIONS : runs

    PROCESSES ||--o{ EXECUTIONS : executed

    BATCHES ||--o{ EXECUTIONS : belongs_to

    BATCHES ||--|| INPUTS : has

    EXECUTIONS ||--|| OUTPUTS : generates

    EXECUTIONS ||--o{ ERRORS : generates

## Optimizations

### Primary and foreign keys:

Primary keys are defined on all tables to ensure unique identification of records and efficient joins between entities.  
Foreign key relationships are used to maintain referential integrity between users, processes, executions, batches, outputs, inputs, and errors.  
The database uses integer-based identifiers instead of storing repeated text values across multiple tables. This reduces storage requirements and simplifies joins.  

### Six views were created for frequently used reporting purposes:

- `execution_summary` -> combines process executions, batches, and errors to simplify troubleshooting and error analysis.  
- `failed_executions` -> shows all the failed executions, identifies failed processes for troubleshooting and process improvement.  
- `execution_errors` -> shows all the executions and the error messages 
- `process_statistics` -> statistics regarding total processes and their success so we know what should improved
- `user_executions_statistics` -> shows number of executions/user 
- `process_execution_ranking` -> execution order + number of executions to build analysis for period of times and to display what are the most used processes 


### Indexes may be created on frequently searched columns such as:

TABLE EXECUTIONS -> user_id

TABLE EXECUTIONS -> batch_id

TABLE EXECUTIONS -> process_id

TABLE EXECUTIONS -> executed_at

TABLE INPUTS -> batch_id

TABLE OUTPUTS -> execution_id

TABLE ERRORS -> execution_id

The indexes were added to improve query performance when filtering or joining records.

### Stored Procedures

The database includes stored procedures for common process management and data validation operations:

- `AddUser` → adds a new accounting user after validating duplicate records.
- `AddProcess` → adds a new process after validating the process name.
- `ChangeName` → updates a user's name after duplicate validation.
- `CorrectProcessName` → corrects a process name while preventing duplicates.
- `DeleteUser` → soft-deletes a user without removing historical execution data.
- `CancelExection` → retrieves errors associated with a specific batch.
- `StartExecution` → creates a batch, stores the input file, and creates a `RUNNING` execution.
- `CompleteExecutionSuccess` → changes the execution status to `SUCCESS` and stores the output file using a transaction.
- `CompleteExecutionFailure` → changes the execution status to `FAILED` and stores the associated error using a transaction.

Stored procedures use input parameters, conditional validation, `SIGNAL`, and `SQLSTATE` for custom validation errors. Transactional procedures also use `COMMIT`, `ROLLBACK`, `EXIT HANDLER`, and `RESIGNAL`.

## SQL Queries

The `queries.sql` file contains queries demonstrating:
- joins across related entities
- filtering and aggregation
- CTEs
- window functions
- execution and error analysis
- process ranking and reporting
  
## Limitations

- Small-team scope: The database is designed for a small team and has not been optimized for enterprise-scale workloads.
- File storage: Input and output files are stored as BLOBs, which increases database storage and backup requirements.
- Concurrency: No job queue or worker architecture is implemented. Concurrent execution of the same process has not been fully designed for production workloads.
- ERP traceability: The system tracks file processing and execution results but does not track changes made inside the ERP after upload.
- Performance: The indexing strategy needs to be improved.
- Recovery: Enterprise-level backup, replication, high availability, and disaster-recovery mechanisms are outside the current scope.

# In progress improvements:

## Automated Testing Framework

A pytest-based automated testing framework is being developed to validate the database layer, including stored procedures, views, tables, constraints and transactional integrity.

**Documentation:** [Epic – Python Automated Testing Framework](User%20Stories/Pytest%20framework/Epic_story.md)

## Future improvements
- BI dashboard for process execution and error analysis
- Explore NoSQL storage, such as MongoDB, for file and document metadata
- Create a separate test environment
- Improve concurrency and scalability
- Optimize database indexing and performance
