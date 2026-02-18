-- ============================================================
--  STUDENT MANAGEMENT SYSTEM
--  File: 04_optimized_queries.sql
--  Description: Views, Stored Procedures, Triggers, Optimization
-- ============================================================

USE student_management;

-- ═══════════════════════════════════════════════
--  VIEWS (Reusable virtual tables)
-- ═══════════════════════════════════════════════

-- V1: Student full profile view
CREATE OR REPLACE VIEW vw_student_profile AS
SELECT
    s.student_id,
    s.enrollment_no,
    CONCAT(s.first_name,' ',s.last_name) AS full_name,
    s.email,
    s.phone,
    s.gender,
    d.dept_name,
    d.dept_code,
    s.join_year,
    s.status,
    TIMESTAMPDIFF(YEAR, s.dob, CURDATE()) AS age
FROM students s
JOIN departments d ON s.dept_id = d.dept_id;

-- V2: Student report card view
CREATE OR REPLACE VIEW vw_report_card AS
SELECT
    s.student_id,
    s.enrollment_no,
    CONCAT(s.first_name,' ',s.last_name) AS student_name,
    c.course_name,
    c.course_code,
    c.credits,
    c.semester,
    g.marks_obtained,
    g.grade_letter,
    g.grade_point
FROM students   s
JOIN enrollments e  ON s.student_id    = e.student_id
JOIN courses     c  ON e.course_id     = c.course_id
LEFT JOIN grades g  ON e.enrollment_id = g.enrollment_id;

-- V3: CGPA summary view
CREATE OR REPLACE VIEW vw_cgpa_summary AS
SELECT
    s.student_id,
    s.enrollment_no,
    CONCAT(s.first_name,' ',s.last_name)                      AS student_name,
    d.dept_name,
    ROUND(SUM(g.grade_point * c.credits)/SUM(c.credits), 2)  AS cgpa,
    ROUND(AVG(g.marks_obtained), 2)                           AS avg_marks
FROM students    s
JOIN departments d  ON s.dept_id       = d.dept_id
JOIN enrollments e  ON s.student_id    = e.student_id
JOIN courses     c  ON e.course_id     = c.course_id
JOIN grades      g  ON e.enrollment_id = g.enrollment_id
GROUP BY s.student_id;

-- V4: Attendance summary view
CREATE OR REPLACE VIEW vw_attendance_summary AS
SELECT
    s.student_id,
    CONCAT(s.first_name,' ',s.last_name) AS student_name,
    c.course_name,
    COUNT(*)                                       AS total_days,
    SUM(a.status = 'Present')                      AS present_days,
    ROUND(SUM(a.status='Present')/COUNT(*)*100, 1) AS attendance_pct
FROM attendance a
JOIN students s ON a.student_id = s.student_id
JOIN courses  c ON a.course_id  = c.course_id
GROUP BY s.student_id, c.course_id;

-- ═══════════════════════════════════════════════
--  STORED PROCEDURES
-- ═══════════════════════════════════════════════

DELIMITER $$

-- SP1: Enroll student and optionally add grade in one call
CREATE PROCEDURE sp_enroll_student(
    IN  p_student_id  INT,
    IN  p_course_id   INT,
    IN  p_teacher_id  INT,
    OUT p_enrollment_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    INSERT INTO enrollments (student_id, course_id, teacher_id, enroll_date)
    VALUES (p_student_id, p_course_id, p_teacher_id, CURDATE());

    SET p_enrollment_id = LAST_INSERT_ID();

    COMMIT;
END$$

-- SP2: Get full student report card
CREATE PROCEDURE sp_get_report_card(IN p_student_id INT)
BEGIN
    -- Basic info
    SELECT * FROM vw_student_profile WHERE student_id = p_student_id;

    -- Course grades
    SELECT course_name, course_code, credits, semester,
           marks_obtained, grade_letter, grade_point
    FROM vw_report_card
    WHERE student_id = p_student_id
    ORDER BY semester, course_name;

    -- CGPA
    SELECT cgpa, avg_marks FROM vw_cgpa_summary WHERE student_id = p_student_id;
END$$

-- SP3: Search students by name, dept, or year
CREATE PROCEDURE sp_search_students(
    IN p_name    VARCHAR(100),
    IN p_dept_id INT,
    IN p_year    YEAR
)
BEGIN
    SELECT * FROM vw_student_profile
    WHERE
        (p_name    IS NULL OR full_name LIKE CONCAT('%', p_name, '%'))
    AND (p_dept_id IS NULL OR dept_name = (SELECT dept_name FROM departments WHERE dept_id = p_dept_id))
    AND (p_year    IS NULL OR join_year = p_year)
    ORDER BY full_name;
END$$

DELIMITER ;

-- ═══════════════════════════════════════════════
--  TRIGGERS
-- ═══════════════════════════════════════════════

DELIMITER $$

-- T1: Prevent enrolling a non-active student
CREATE TRIGGER trg_check_student_active
BEFORE INSERT ON enrollments
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(20);
    SELECT status INTO v_status FROM students WHERE student_id = NEW.student_id;
    IF v_status != 'Active' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot enroll: Student is not Active.';
    END IF;
END$$

-- T2: Log when a grade is updated (audit trail)
CREATE TABLE IF NOT EXISTS grade_audit_log (
    log_id       INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id INT,
    old_marks    DECIMAL(5,2),
    new_marks    DECIMAL(5,2),
    changed_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)$$

CREATE TRIGGER trg_grade_update_log
AFTER UPDATE ON grades
FOR EACH ROW
BEGIN
    IF OLD.marks_obtained != NEW.marks_obtained THEN
        INSERT INTO grade_audit_log (enrollment_id, old_marks, new_marks)
        VALUES (NEW.enrollment_id, OLD.marks_obtained, NEW.marks_obtained);
    END IF;
END$$

DELIMITER ;

-- ═══════════════════════════════════════════════
--  OPTIMIZED ANALYTICAL QUERIES
-- ═══════════════════════════════════════════════

-- Q1: Rank students by CGPA within each department (Window Function)
SELECT
    dept_name,
    student_name,
    cgpa,
    RANK() OVER (PARTITION BY dept_name ORDER BY cgpa DESC) AS dept_rank
FROM vw_cgpa_summary
ORDER BY dept_name, dept_rank;

-- Q2: Running cumulative average of marks per student (Window Function)
SELECT
    student_name,
    course_name,
    semester,
    marks_obtained,
    ROUND(AVG(marks_obtained) OVER (
        PARTITION BY student_id
        ORDER BY semester
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ), 2) AS running_avg
FROM vw_report_card
WHERE marks_obtained IS NOT NULL
ORDER BY student_name, semester;

-- Q3: Students who passed ALL enrolled courses
SELECT
    student_name,
    enrollment_no,
    dept_name
FROM vw_student_profile sp
WHERE student_id IN (
    SELECT e.student_id
    FROM enrollments e
    JOIN grades g ON e.enrollment_id = g.enrollment_id
    GROUP BY e.student_id
    HAVING MIN(g.marks_obtained) >= 40   -- 40 is pass mark
)
ORDER BY student_name;

-- Q4: Courses with average marks < 60 (at-risk courses)
SELECT
    c.course_name,
    c.course_code,
    d.dept_name,
    COUNT(g.grade_id)           AS students_graded,
    ROUND(AVG(g.marks_obtained),2) AS avg_marks,
    SUM(g.marks_obtained < 40)  AS failed_count
FROM courses c
JOIN departments d  ON c.dept_id = d.dept_id
JOIN enrollments e  ON c.course_id = e.course_id
JOIN grades      g  ON e.enrollment_id = g.enrollment_id
GROUP BY c.course_id
HAVING avg_marks < 60
ORDER BY avg_marks;

-- Q5: Students with attendance below 75% in any course
SELECT
    student_name,
    course_name,
    attendance_pct
FROM vw_attendance_summary
WHERE attendance_pct < 75
ORDER BY attendance_pct;

-- Q6: Monthly enrollment trend using DATE functions
SELECT
    YEAR(enroll_date)  AS year,
    MONTH(enroll_date) AS month,
    MONTHNAME(enroll_date) AS month_name,
    COUNT(*) AS enrollments
FROM enrollments
GROUP BY YEAR(enroll_date), MONTH(enroll_date)
ORDER BY year, month;
