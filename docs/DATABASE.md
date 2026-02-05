# Database Schema
Documentation for the PostgreSQL schema used in Budget App.

## Tables
- `users`: User accounts and authentication details
- `budgets`: Monthly budget configuration and tracking
- `transactions`: Individual expense/income records
- `categories`: User-defined categories (e.g., Food, Rent)
- `budget_types`: Recurring budget identifiers
- `recurrings`: Configuration for recurring transactions

## Seeds
Sample data seeds are located in `database/seed/`.
- `sample_import.csv`: Example CSV for testing uploads.
- `user_data.json`: Example user configuration.

## Schema
Schema definition files are located in `database/schema/`.
- `migrations.sql`: Core table creation script.
