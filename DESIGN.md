# Diagram design Document

- By Orsa Ionut Cristian
- Made with MermaidJs

## ErDiagram

    
    USERS {
        SMALLINT user_id PK "AUTO_INCREMENT"
        VARCHAR(20) first_name "NOT NULL"
        VARCHAR(20) last_name "NOT NULL"
        DATETIME created_at "NOT NULL DEFAULT CURRENT_TIMESTAMP"
        BOOLEAN deleted "NOT NULL DEFAULT FALSE"
    }

    PROCESSES {
        INTEGER process_id PK "AUTO_INCREMENT"
        VARCHAR(100) name "NOT NULL UNIQUE"
        BOOLEAN deleted "NOT NULL DEFAULT FALSE"
        DATETIME created_at "NOT NULL DEFAULT CURRENT_TIMESTAMP"
    }

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

    INPUTS {
        INTEGER input_id PK "AUTO_INCREMENT NOT NULL"
        INTEGER batch_id FK "NOT NULL"
        MEDIUMBLOB input "NOT NULL"
    }

    OUTPUTS {
        INTEGER output_id PK "AUTO_INCREMENT NOT NULL"
        INTEGER execution_id FK "NOT NULL"
        MEDIUMBLOB output "NOT NULL"
    }

    ERRORS {
        INTEGER error_id PK "AUTO_INCREMENT NOT NULL"
        INTEGER execution_id FK "NOT NULL"
        VARCHAR(400) error_msg "NOT NULL"

    }

    USERS ||--o{ EXECUTIONS : runs
    EXECUTIONS ||--o{ ERRORS : generates
    EXECUTIONS ||--|| OUTPUTS : generates
    BATCHES ||--|| INPUTS : has
    BATCHES ||--o{ EXECUTIONS : belongs_to
    PROCESSES ||--o{ EXECUTIONS : executed



![DatabaseDiagram](Diagram.jpg)
