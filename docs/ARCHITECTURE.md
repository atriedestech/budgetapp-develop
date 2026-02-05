# Budget App Architecture
This document describes the high-level architecture of the Budget App.

## Backend
- **Framework**: Dropwizard (Jersey, Jackson, Hibernate)
- **Database**: PostgreSQL (Migrations using Liquibase/SQL)
- **Build Tool**: Maven

## Frontend
- **Framework**: AngularJS (1.x)
- **Styling**: Bootstrap, LESS
- **Build Tool**: Gulp/NPM

## Directory Structure
- `src/main/java`: Backend source code
- `src/main/resources/app`: Frontend source code
- `config/`: Application configuration (YAML)
- `database/`: SQL scripts and seeds
- `scripts/`: Helper utilities (run.sh, db_start.sh)

