# Student Management System (MySQL)
### A Complete Fresher's Project — From Scratch to End

---

## Project Overview

A relational database-backed system to manage students, departments, courses, enrollments, grades, and attendance. Built with **MySQL** + optional **Python CLI**.

---

## Tech Stack

| Layer      | Technology              |
|------------|-------------------------|
| Database   | MySQL 8.0+              |
| Language   | SQL (DDL, DML, DCL)     |
| Interface  | Python 3 (optional CLI) |
| Connector  | mysql-connector-python  |

---

## Database Schema (ER Diagram)

```
departments ──< courses
     │
     └──< students ──< enrollments >── courses
                             │
                         enrollments ──< grades
                         students    ──< attendance >── courses
```

### Tables

| Table        | Purpose                                  |
|--------------|------------------------------------------|
| `departments`| College departments (CS, ECE, etc.)      |
| `courses`    | Courses offered by each department       |
| `students`   | Student personal & academic info         |
| `teachers`   | Faculty members                          |
| `enrollments`| Student ↔ Course mapping                 |
| `grades`     | Marks, grade letter, grade point         |
| `attendance` | Daily per-student per-course attendance  |

---

## Normalization (3NF)

- **1NF**: All attributes are atomic; no repeating groups.
- **2NF**: No partial dependencies (all non-key columns depend on full PK).
- **3NF**: No transitive dependencies (e.g., `grade_letter` is derived via stored generated column, not stored redundantly).

---

## Key Features

### Schema Design
- Auto-increment primary keys
- Foreign key constraints with `ON DELETE CASCADE / RESTRICT`
- `ENUM` for controlled vocabulary (status, gender)
- `GENERATED ALWAYS AS` columns for grade letter & grade point (no redundancy)
- Strategic `INDEX` creation for performance

### CRUD Operations
- **CREATE** — Add students, enroll in courses, record grades, mark attendance
- **READ** — Student profiles, report cards, CGPA, attendance %, department stats
- **UPDATE** — Contact info, marks correction, teacher assignment, department HOD
- **DELETE** — Soft delete (status = 'Dropped') + hard delete with CASCADE

### Optimized Queries
- **Views** for frequently accessed data (vw_report_card, vw_cgpa_summary, etc.)
- **Stored Procedures** for multi-step operations (enroll + grade in one call)
- **Triggers** for business rules (only active students can enroll) and audit logging
- **Window Functions** — RANK(), running AVG() for analytics
- **Indexes** on foreign keys and commonly filtered columns

---

## Setup Instructions

### Step 1 — Install MySQL
```bash
# Ubuntu/Debian
sudo apt install mysql-server

# macOS (Homebrew)
brew install mysql
```

### Step 2 — Run SQL Files in Order
```bash
mysql -u root -p < 01_schema.sql
mysql -u root -p < 02_sample_data.sql
mysql -u root -p < 03_crud_operations.sql
mysql -u root -p < 04_optimized_queries.sql
```

Or inside MySQL shell:
```sql
SOURCE /path/to/01_schema.sql;
SOURCE /path/to/02_sample_data.sql;
```

### Step 3 — Run Python CLI (Optional)
```bash
pip install mysql-connector-python
# Edit DB_CONFIG in student_management.py with your credentials
python student_management.py
```

---

## File Structure

```
student_management_system/
│
├── 01_schema.sql           # Table definitions, indexes, constraints
├── 02_sample_data.sql      # 10 students, courses, grades, attendance
├── 03_crud_operations.sql  # All INSERT / SELECT / UPDATE / DELETE
├── 04_optimized_queries.sql# Views, Stored Procs, Triggers, Analytics
├── student_management.py   # Python CLI interface
└── README.md               # This file
```

---

## Sample Queries You Can Try

```sql
-- Get report card for student ID 1
CALL sp_get_report_card(1);

-- Search student by name
CALL sp_search_students('Priya', NULL, NULL);

-- Top students by CGPA
SELECT * FROM vw_cgpa_summary ORDER BY cgpa DESC LIMIT 5;

-- Students with low attendance
SELECT * FROM vw_attendance_summary WHERE attendance_pct < 75;

-- Rank students within departments
SELECT dept_name, student_name, cgpa,
       RANK() OVER (PARTITION BY dept_name ORDER BY cgpa DESC) AS dept_rank
FROM vw_cgpa_summary;
```

---

## Resume Points (How to Describe This Project)

- **Designed** a normalized relational database schema (3NF) with 7 tables, FK constraints, and ENUM types
- **Implemented** full CRUD operations using DDL/DML with cascading deletes and soft-delete pattern
- **Optimized** data retrieval with indexed foreign keys, reusable Views, and Window Functions (RANK, running AVG)
- **Built** Stored Procedures for transactional multi-step operations and Triggers for business rule enforcement and audit logging
- **Developed** a Python CLI using `mysql-connector-python` for interactive student record management

---

*Project built for learning purposes. Suitable for college mini-project submission.*
