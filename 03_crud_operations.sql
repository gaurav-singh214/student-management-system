-- ============================================================
--  STUDENT MANAGEMENT SYSTEM
--  File: 03_crud_operations.sql
--  Description: Full CREATE, READ, UPDATE, DELETE operations
-- ============================================================

USE student_management;

-- ═══════════════════════════════════════════════
--  CREATE (INSERT) OPERATIONS
-- ═══════════════════════════════════════════════

-- C1: Add a new student
INSERT INTO students (first_name, last_name, email, phone, dob, gender, dept_id, enrollment_no, join_year, address)
VALUES ('Rahul', 'Verma', 'rahul.verma@student.edu', '9988776655',
        '2003-04-10', 'Male', 1, 'CS2022001', 2022, '88 Rajouri Garden, Delhi');

-- C2: Enroll a student in a course
INSERT INTO enrollments (student_id, course_id, teacher_id, enroll_date)
VALUES (LAST_INSERT_ID(), 1, 1, CURDATE());

-- C3: Add grade for an enrollment
INSERT INTO grades (enrollment_id, marks_obtained, exam_date, remarks)
VALUES (LAST_INSERT_ID(), 85.00, '2022-11-25', 'Good performance');

-- C4: Mark attendance
INSERT INTO attendance (student_id, course_id, att_date, status)
VALUES (1, 1, CURDATE(), 'Present');

-- ═══════════════════════════════════════════════
--  READ (SELECT) OPERATIONS
-- ═══════════════════════════════════════════════

-- R1: Get all active students with their department
SELECT
    s.student_id,
    CONCAT(s.first_name,' ', s.last_name) AS full_name,
    s.enrollment_no,
    s.email,
    d.dept_name,
    s.join_year,
    s.status
FROM students s
JOIN departments d ON s.dept_id = d.dept_id
WHERE s.status = 'Active'
ORDER BY s.join_year DESC, s.last_name;

-- R2: Get a specific student's full profile
SELECT
    s.student_id,
    CONCAT(s.first_name,' ',s.last_name) AS full_name,
    s.enrollment_no,
    s.email,
    s.phone,
    s.dob,
    TIMESTAMPDIFF(YEAR, s.dob, CURDATE()) AS age,
    s.gender,
    d.dept_name,
    s.join_year,
    s.status
FROM students s
JOIN departments d ON s.dept_id = d.dept_id
WHERE s.student_id = 1;

-- R3: Get all courses a student is enrolled in with grades
SELECT
    c.course_name,
    c.course_code,
    c.credits,
    c.semester,
    CONCAT(t.full_name) AS teacher,
    g.marks_obtained,
    g.grade_letter,
    g.grade_point
FROM enrollments e
JOIN courses    c ON e.course_id  = c.course_id
LEFT JOIN teachers  t ON e.teacher_id = t.teacher_id
LEFT JOIN grades    g ON e.enrollment_id = g.enrollment_id
WHERE e.student_id = 1
ORDER BY c.semester;

-- R4: Calculate CGPA for a student
SELECT
    s.student_id,
    CONCAT(s.first_name,' ',s.last_name) AS full_name,
    ROUND(SUM(g.grade_point * c.credits) / SUM(c.credits), 2) AS cgpa
FROM students   s
JOIN enrollments e ON s.student_id  = e.student_id
JOIN courses     c ON e.course_id   = c.course_id
JOIN grades      g ON e.enrollment_id = g.enrollment_id
WHERE s.student_id = 1;

-- R5: Attendance percentage per student per course
SELECT
    CONCAT(s.first_name,' ',s.last_name) AS student_name,
    c.course_name,
    COUNT(*)                                    AS total_classes,
    SUM(a.status = 'Present')                   AS present,
    SUM(a.status = 'Absent')                    AS absent,
    ROUND(SUM(a.status='Present')/COUNT(*)*100,1) AS attendance_pct
FROM attendance a
JOIN students s ON a.student_id = s.student_id
JOIN courses  c ON a.course_id  = c.course_id
GROUP BY s.student_id, c.course_id
ORDER BY attendance_pct DESC;

-- R6: Department-wise student count
SELECT
    d.dept_name,
    d.dept_code,
    COUNT(s.student_id) AS total_students,
    SUM(s.status='Active') AS active
FROM departments d
LEFT JOIN students s ON d.dept_id = s.dept_id
GROUP BY d.dept_id
ORDER BY total_students DESC;

-- R7: Top 5 performing students overall
SELECT
    CONCAT(s.first_name,' ',s.last_name) AS student_name,
    s.enrollment_no,
    d.dept_name,
    ROUND(AVG(g.marks_obtained),2) AS avg_marks,
    ROUND(SUM(g.grade_point * c.credits)/SUM(c.credits),2) AS cgpa
FROM students   s
JOIN departments d  ON s.dept_id       = d.dept_id
JOIN enrollments e  ON s.student_id    = e.student_id
JOIN grades      g  ON e.enrollment_id = g.enrollment_id
JOIN courses     c  ON e.course_id     = c.course_id
GROUP BY s.student_id
ORDER BY cgpa DESC
LIMIT 5;

-- R8: Students with low attendance (<75%)
SELECT
    CONCAT(s.first_name,' ',s.last_name) AS student_name,
    c.course_name,
    ROUND(SUM(a.status='Present')/COUNT(*)*100,1) AS attendance_pct
FROM attendance a
JOIN students s ON a.student_id = s.student_id
JOIN courses  c ON a.course_id  = c.course_id
GROUP BY s.student_id, c.course_id
HAVING attendance_pct < 75
ORDER BY attendance_pct;

-- ═══════════════════════════════════════════════
--  UPDATE OPERATIONS
-- ═══════════════════════════════════════════════

-- U1: Update student contact info
UPDATE students
SET phone   = '9112233445',
    address = '99 New Colony, Bengaluru'
WHERE student_id = 1;

-- U2: Update student status to Graduated
UPDATE students
SET status = 'Graduated'
WHERE student_id = 3;

-- U3: Correct a student's marks
UPDATE grades
SET marks_obtained = 89.0,
    remarks = 'Re-evaluated'
WHERE enrollment_id = 1;

-- U4: Change teacher assigned to a course enrollment
UPDATE enrollments
SET teacher_id = 2
WHERE student_id = 1 AND course_id = 2;

-- U5: Update HOD of a department
UPDATE departments
SET hod_name = 'Dr. Neeraj Agarwal'
WHERE dept_code = 'CS';

-- ═══════════════════════════════════════════════
--  DELETE OPERATIONS
-- ═══════════════════════════════════════════════

-- D1: Remove a specific attendance record
DELETE FROM attendance
WHERE student_id = 1 AND course_id = 1 AND att_date = CURDATE();

-- D2: Remove a student's enrollment from a course
--     (Grade is deleted automatically via CASCADE)
DELETE FROM enrollments
WHERE student_id = 9 AND course_id = 4;

-- D3: Soft delete — mark student as Dropped (preferred over hard delete)
UPDATE students
SET status = 'Dropped'
WHERE student_id = 10;

-- D4: Hard delete a student (cascades enrollments, grades, attendance)
-- ⚠️  Use with caution — data is permanently removed
-- DELETE FROM students WHERE student_id = 99;
