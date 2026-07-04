# Design Document

By Orsa Ionut Cristian

Video overview: <URL HERE>

## Scope

In this section you should answer the following questions:

* What is the purpose of your database?

The purpose of this database is to have an audit trail of the scripts that my team were using and the the executions performed by automated scripts and the files processed during those executions.

* Which people, places, things, etc. are you including in the scope of your database?

- Users from my team that are using the scripts
- The input data from Oracle
- The output data that will be uploaded in oracle
- The name and details of the scripts that were used
- An error/ process status table

* Which people, places, things, etc. are *outside* the scope of your database?


- Financial data stored inside Oracle Fusion
- Validation of accounting data correctness
- Business approval workflows


## Functional Requirements

In this section you should answer the following questions:

* What should a user be able to do with your database?

When using a script that automates an Oracle Fusion Financials process the user should be able to have an audit trail.

* What's beyond the scope of what a user should be able to do with your database?

This database is needed only for audit trail and error checking, the user should not use this data to check if the financial data from Accounting is correct. To check if the data is correct the user should look directly in Oracle Fusion.

## Representation

    USERS {
        tiny int user_id PK
        string first_name VARCHAR(50)
        string last_name VARCHAR(50)
    }

    PROCESSES {
        int process_id PK
        string name VARCHAR(100)
        bool deleted
    }

    EXECUTIONS {
        int execution_id PK
        int process_id FK
        tiny int user_id FK
        int batch_id FK
        datetime executed_at
        VARCHAR(50) enum('SUCCESS','FAILED','RUNNING')
    }

    BATCHES {
        int batch_id PK
        datetime created_at
    }

    INPUTS {
        int input_id PK
        int batch_id FK
        blob input
    }

    OUTPUTS {
        int output_id PK
        int execution_id FK
        blob output
    }

    ERRORS {
        int error_id PK
        int execution_id FK
        string error_msg VARCHAR(400)
    }

### Entities

In this section you should answer the following questions:

* Which entities will you choose to represent in your database?

Users, processes, executions, batches, inputs, outputs, and errors.

* What attributes will those entities have?

The entities use integer identifiers and foreign keys, VARCHAR fields for names and messages, BLOB fields for storing the original input and output files, BOOLEAN fields for process flags, and DATETIME fields for execution timestamps.

* Why did you choose the types you did?

The database uses integers for identifiers and foreign keys, VARCHAR fields for names and error messages, BLOB fields for storing the original Excel files used as inputs and outputs, BOOLEAN fields for logical flags, and DATETIME fields for recording execution timestamps.

* Why did you choose the constraints you did?

Primary key constraints are used to uniquely identify records in every table.
Foreign key constraints are used to enforce relationships between users, processes, executions, batches and errors.
The deleted attribute in the Processes table is represented as a Boolean value so that processes can be soft-deleted without losing historical execution data.
VARCHAR limits were chosen based on expected data sizes to avoid unnecessary storage usage while still providing sufficient flexibility.

### Relationships

In this section you should include your entity relationship diagram and describe the relationships between the entities in your database.

![DatabaseDiagram](Diagram.jpg)


    USERS ||--o{ EXECUTIONS : runs

    PROCESSES ||--o{ EXECUTIONS : executed

    BATCHES ||--o{ EXECUTIONS : belongs_to

    BATCHES ||--|| INPUTS : has

    EXECUTIONS ||--|| OUTPUTS : generates

    EXECUTIONS ||--o{ ERRORS : generates

## Optimizations

In this section you should answer the following questions:

* Which optimizations (e.g., indexes, views) did you create? Why?

Primary keys are defined on all tables to ensure unique identification of records and efficient joins between entities.
Foreign key relationships are used to maintain referential integrity between users, processes, executions, batches, outputs, inputs, and errors.
The database uses integer-based identifiers instead of storing repeated text values across multiple tables. This reduces storage requirements and simplifies joins.
Two views were created for frequently used reporting purposes:

A view that combines process executions, batches, and errors to simplify troubleshooting and error analysis.
A view that combines execution information with input and output files to simplify audit trail reporting.

Indexes may be created on frequently searched columns such as:

execution_id
process_id
user_id
batch_id

to improve query performance when filtering or joining records.

## Limitations

In this section you should answer the following questions:

* What are the limitations of your design?

The database was designed for a small team and focuses primarily on audit trail functionality rather than complete process management.
The database stores input and output files as BLOB objects. While this preserves the original files for audit purposes, it increases storage requirements compared to storing only the processed data.

* What might your database not be able to represent very well?

The database does not track modifications performed inside Oracle Fusion after a file has been uploaded. It only records which files were processed and uploaded by each execution.
The design assumes that each execution generates a single output file. If future requirements require multiple output files per execution, the schema would need to be extended.
The database is intended for a small team and is not optimized for large-scale enterprise workloads involving millions of executions or file uploads.
