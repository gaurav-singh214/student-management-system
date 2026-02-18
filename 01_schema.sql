-- ============================================================
--  STUDENT MANAGEMENT SYSTEM
--  File: 01_schema.sql
--  Description: Database schema with normalized tables (3NF)
-- ============================================================

-- Create and use the database
CREATE DATABASE IF NOT EXISTS student_management;
USE student_management;

-- ─────────────────────────────────────────────
-- 1. DEPARTMENTS TABLE
-- ─────────────────────────────────────────────
CREATE TABLE departments (
    dept_id      INT           AUTO_INCREMENT PRIMARY KEY,
    dept_name    VARCHAR(100)  NOT NULL UNIQUE,
    dept_code    CHAR(5)       NOT NULL UNIQUE,
    hod_name     VARCHAR(100),
    created_at   TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);

-- ─────────────────────────────────────────────
-- 2. COURSES TABLE
-- ─────────────────────────────────────────────
CREATE TABLE courses (
    course_id    INT           AUTO_INCREMENT PRIMARY KEY,
    course_name  VARCHAR(150)  NOT NULL,
    course_code  VARCHAR(20)   NOT NULL UNIQUE,
    dept_id      INT           NOT NULL,
    credits      TINYINT       NOT NULL CHECK (credits BETWEEN 1 AND 6),
    semester     TINYINT       NOT NULL CHECK (semester BETWEEN 1 AND 8),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id) ON DELETE CASCADE
);

-- ─────────────────────────────────────────────
-- 3. STUDENTS TABLE
-- ─────────────────────────────────────────────
CREATE TABLE students (
    student_id   INT           AUTO_INCREMENT PRIMARY KEY,
    first_name   VARCHAR(50)   NOT NULL,
    last_name    VARCHAR(50)   NOT NULL,
    email        VARCHAR(100)  NOT NULL UNIQUE,
    phone        VARCHAR(15),
    dob          DATE          NOT NULL,
    gender       ENUM('Male','Female','Other') NOT NULL,
    dept_id      INT           NOT NULL,
    enrollment_no VARCHAR(20)  NOT NULL UNIQUE,
    join_year    YEAR          NOT NULL,
    status       ENUM('Active','Inactive','Graduated','Dropped') DEFAULT 'Active',
    address      TEXT,
    created_at   TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id) ON DELETE RESTRICT
);

-- ─────────────────────────────────────────────
-- 4. TEACHERS TABLE
-- ─────────────────────────────────────────────
CREATE TABLE teachers (
    teacher_id   INT           AUTO_INCREMENT PRIMARY KEY,
    full_name    VARCHAR(100)  NOT NULL,
    email        VARCHAR(100)  NOT NULL UNIQUE,
    dept_id      INT           NOT NULL,
    designation  VARCHAR(80),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id) ON DELETE RESTRICT
);

-- ─────────────────────────────────────────────
-- 5. ENROLLMENTS TABLE (Student ↔ Course)
-- ─────────────────────────────────────────────
CREATE TABLE enrollments (
    enrollment_id INT     AUTO_INCREMENT PRIMARY KEY,
    student_id    INT     NOT NULL,
    course_id     INT     NOT NULL,
    teacher_id    INT,
    enroll_date   DATE    NOT NULL DEFAULT (CURRENT_DATE),
    UNIQUE KEY uq_student_course (student_id, course_id),
    FOREIGN KEY (student_id)  REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id)   REFERENCES courses(course_id)   ON DELETE CASCADE,
    FOREIGN KEY (teacher_id)  REFERENCES teachers(teacher_id) ON DELETE SET NULL
);

-- ─────────────────────────────────────────────
-- 6. GRADES TABLE
-- ─────────────────────────────────────────────
CREATE TABLE grades (
    grade_id      INT           AUTO_INCREMENT PRIMARY KEY,
    enrollment_id INT           NOT NULL UNIQUE,
    marks_obtained DECIMAL(5,2) NOT NULL CHECK (marks_obtained BETWEEN 0 AND 100),
    grade_letter  CHAR(2)       GENERATED ALWAYS AS (
        CASE
            WHEN marks_obtained >= 90 THEN 'A+'
            WHEN marks_obtained >= 80 THEN 'A'
            WHEN marks_obtained >= 70 THEN 'B+'
            WHEN marks_obtained >= 60 THEN 'B'
            WHEN marks_obtained >= 50 THEN 'C'
            WHEN marks_obtained >= 40 THEN 'D'
            ELSE 'F'
        END
    ) STORED,
    grade_point   DECIMAL(3,1)  GENERATED ALWAYS AS (
        CASE
            WHEN marks_obtained >= 90 THEN 10.0
            WHEN marks_obtained >= 80 THEN 9.0
            WHEN marks_obtained >= 70 THEN 8.0
            WHEN marks_obtained >= 60 THEN 7.0
            WHEN marks_obtained >= 50 THEN 6.0
            WHEN marks_obtained >= 40 THEN 5.0
            ELSE 0.0
        END
    ) STORED,
    exam_date     DATE,
    remarks       VARCHAR(200),
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id) ON DELETE CASCADE
);

-- ─────────────────────────────────────────────
-- 7. ATTENDANCE TABLE
-- ─────────────────────────────────────────────
CREATE TABLE attendance (
    att_id        INT   AUTO_INCREMENT PRIMARY KEY,
    student_id    INT   NOT NULL,
    course_id     INT   NOT NULL,
    att_date      DATE  NOT NULL,
    status        ENUM('Present','Absent','Late') NOT NULL DEFAULT 'Present',
    UNIQUE KEY uq_att (student_id, course_id, att_date),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id)  REFERENCES courses(course_id)  ON DELETE CASCADE
);

-- ─────────────────────────────────────────────
-- INDEXES for performance optimization
-- ─────────────────────────────────────────────
CREATE INDEX idx_students_dept       ON students(dept_id);
CREATE INDEX idx_students_status     ON students(status);
CREATE INDEX idx_students_join_year  ON students(join_year);
CREATE INDEX idx_enrollments_student ON enrollments(student_id);
CREATE INDEX idx_enrollments_course  ON enrollments(course_id);
CREATE INDEX idx_attendance_date     ON attendance(att_date);
CREATE INDEX idx_grades_grade_letter ON grades(grade_letter);
