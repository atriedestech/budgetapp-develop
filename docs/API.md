# API Documentation
REST API endpoint documentation.

Base URL: `/api`

## Authentication
- `POST /users`: Signup
- `POST /users/auth`: Login (Returns Token)

## Budgets
- `GET /budgets`: List budgets
- `POST /budgets`: Create budget
- `GET /budgets/{month}/{year}`: Get monthly usage

## Transactions
- `POST /transactions`: Create transaction
- `GET /transactions`: List recent transactions
- `GET /transactions/summary`: Get spending summary

## Categories
- `GET /categories`: List categories
- `POST /categories`: Create category
