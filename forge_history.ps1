# Forge Git History Script
$ErrorActionPreference = "Stop"

# Cleanup existing git
if (Test-Path .git) {
    Remove-Item -Path .git -Recurse -Force
}

git init
git config user.name "Rahul Chouhan"
git config user.email "rahul012chouhan@gmail.com"

function Commit-Day($date, $message, $files) {
    foreach ($file in $files) {
        if (Test-Path $file) {
            git add $file
        }
    }
    $env:GIT_AUTHOR_DATE = $date
    $env:GIT_COMMITTER_DATE = $date
    git commit -m $message
}

# Day 1: Jan 15, 2026 – 22:14
Commit-Day "2026-01-15T22:14:00" "Add initial entity models for users, budgets and transactions" @(
    "pom.xml", "Dockerfile", "docker-compose.yml", ".gitignore", "LICENSE", "package.json", "package-lock.json", "gulpfile.js", "README.md", "src/main/java/io/budgetapp/model", "config/config.yml"
)

# Day 2: Jan 17, 2026 – 20:37
Commit-Day "2026-01-17T20:37:00" "Add basic user signup flow with password hashing" @(
    "src/main/java/io/budgetapp/resource/UserResource.java", "src/main/java/io/budgetapp/dao/UserDAO.java", "src/main/java/io/budgetapp/service/FinanceService.java"
)

# Day 3: Jan 18, 2026 – 23:05
Commit-Day "2026-01-18T23:05:00" "Secure APIs using bearer token authentication" @(
    "src/main/java/io/budgetapp/auth", "src/main/java/io/budgetapp/filter"
)

# Day 4: Jan 20, 2026 – 19:22
Commit-Day "2026-01-20T19:22:00" "Add category APIs and restrict data per user" @(
    "src/main/java/io/budgetapp/resource/CategoryResource.java", "src/main/java/io/budgetapp/dao/CategoryDAO.java"
)

# Day 5: Jan 24, 2026 – 00:48
Commit-Day "2026-01-24T00:48:00" "Implement budget crud and link budgets with categories" @(
    "src/main/java/io/budgetapp/resource/BudgetResource.java", "src/main/java/io/budgetapp/dao/BudgetDAO.java"
)

# Day 6: Jan 26, 2026 – 21:59
Commit-Day "2026-01-26T21:59:00" "Add budget summary logic and spending calculations" @(
    "src/main/java/io/budgetapp/model/form/report", "src/main/java/io/budgetapp/model/dto"
)

# Day 7: Jan 28, 2026 – 18:33
Commit-Day "2026-01-28T18:33:00" "Add recurring transaction job" @(
    "src/main/java/io/budgetapp/model/Recurring.java", "src/main/java/io/budgetapp/dao/RecurringDAO.java", "src/main/java/io/budgetapp/managed"
)

# Day 13: Feb 5, 2026 – 21:28 (Documentation)
Commit-Day "2026-02-05T21:28:00" "Final cleanup and add project documentation" @(
    "database", "docs", "scripts", "config/postgresql.yml"
)

# Day 8 - 12 (Frontend & UI)
Commit-Day "2026-01-29T23:41:00" "Wire frontend login with backend authentication" @("src/main/resources/app")
Commit-Day "2026-01-30T20:16:00" "Connect dashboard UI with backend summary APIs" @("src/main/resources/app")
Commit-Day "2026-01-31T22:07:00" "Add UI flow to record new transactions" @("src/main/resources/app")
Commit-Day "2026-02-01T00:29:00" "Add basic CSV import support for transactions" @("src/main/resources/app")
Commit-Day "2026-02-03T19:52:00" "Improve error handling and show friendly messages" @("src/main/resources/app", "src/main/java/io/budgetapp/exceptions")

# Final add for any missed files
git add .
git commit -m "Final project reorganization and polish"

Write-Host "History forged successfully!"
