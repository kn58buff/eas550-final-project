🗄️ CSV to 3NF Data Pipeline

Raw CSV Data → Structured PostgreSQL Database → Fully Normalized 3NF Schema

An end-to-end data engineering pipeline that ingests raw CSV datasets into PostgreSQL and transforms them into a fully normalized relational database (Third Normal Form) using SQL-based transformations.

This project demonstrates real-world database engineering practices, including schema design, normalization, and structured ETL pipelines.

✨ Key Features
📥 CSV Data Ingestion

Automated ingestion of raw CSV datasets

Python pipeline loads data into PostgreSQL staging tables

Designed for scalable dataset ingestion

🗄️ Relational Database Design

PostgreSQL schema designed using Third Normal Form (3NF)

Eliminates redundancy and improves data consistency

Maintains clear relationships between entities

🔄 SQL-Based Data Transformation

Raw data stored in staging tables

SQL scripts transform raw data into normalized relational tables

Clear separation between data ingestion and data modeling

🏗️ Production-Style Project Architecture

The project follows a modular data engineering architecture with separation between:

ingestion layer

database schema

SQL transformations

analytics layer

This mirrors how real data engineering systems are designed in production environments.

🏗️ System Architecture
Raw CSV Data
     │
     ▼
Python Ingestion Pipeline
(src/ingestion)
     │
     ▼
PostgreSQL Staging Tables
     │
     ▼
SQL Transformation Layer
(sql/schema.sql)
     │
     ▼
Normalized 3NF Database
     │
     ▼
Analytics / Dashboard


🔎 Why this matters: Separating ingestion from transformation improves scalability, maintainability, and data quality in real-world data platforms.

📂 Project Structure
eas550-final-project/
│
├── data/
│   └── raw/                 # Raw CSV datasets
│
├── dashboard/               # Analytics / dashboard layer
│
├── reports/                 # Generated reports
│
├── sql/
│   ├── schema.sql           # Database schema and normalization logic
│   └── security.sql         # Database roles and permissions
│
├── src/
│   ├── ingestion/
│   │   └── ingest_data.py   # CSV → PostgreSQL ingestion pipeline
│   │
│   ├── db/
│   │   └── connection.py    # PostgreSQL connection utilities
│   │
│   └── utils/
│       └── helpers.py       # Helper functions
│
├── requirements.txt
└── README.md

⚙️ Tech Stack
Python
PostgreSQL
Pandas
psycopg2 / SQLAlchemy
SQL
Git

Authors:
Kevin Ngyuen
Tsomorlig Khishigbold
Vedant Shinde