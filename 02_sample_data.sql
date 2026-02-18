-- ============================================================
--  STUDENT MANAGEMENT SYSTEM
--  File: 02_sample_data.sql
--  Description: INSERT sample records for testing
-- ============================================================

USE student_management;

-- ─────────────────────────────────────────────
-- DEPARTMENTS
-- ─────────────────────────────────────────────
INSERT INTO departments (dept_name, dept_code, hod_name) VALUES
('Computer Science',        'CS',    'Dr. Rajan Mehta'),
('Electronics Engineering', 'ECE',   'Dr. Priya Sharma'),
('Mechanical Engineering',  'MECH',  'Dr. Arjun Verma'),
('Civil Engineering',       'CIVIL', 'Dr. Sunita Nair'),
('Information Technology',  'IT',    'Dr. Kavya Reddy');

-- ─────────────────────────────────────────────
-- COURSES
-- ─────────────────────────────────────────────
INSERT INTO courses (course_name, course_code, dept_id, credits, semester) VALUES
('Data Structures & Algorithms',  'CS101', 1, 4, 2),
('Database Management Systems',   'CS102', 1, 4, 3),
('Operating Systems',             'CS103', 1, 3, 4),
('Computer Networks',             'CS104', 1, 3, 5),
('Web Development',               'CS105', 1, 3, 3),
('Circuit Theory',                'ECE101',2, 4, 1),
('Digital Electronics',           'ECE102',2, 4, 2),
('Thermodynamics',                'ME101', 3, 4, 2),
('Structural Analysis',           'CV101', 4, 4, 3),
('Python Programming',            'IT101', 5, 3, 1);

-- ─────────────────────────────────────────────
-- TEACHERS
-- ─────────────────────────────────────────────
INSERT INTO teachers (full_name, email, dept_id, designation) VALUES
('Prof. Anil Kumar',   'anil.kumar@college.edu',   1, 'Associate Professor'),
('Prof. Meena Iyer',   'meena.iyer@college.edu',   1, 'Assistant Professor'),
('Prof. Ravi Tiwari',  'ravi.tiwari@college.edu',  2, 'Professor'),
('Prof. Geeta Bose',   'geeta.bose@college.edu',   3, 'Assistant Professor'),
('Prof. Harish Negi',  'harish.negi@college.edu',  5, 'Associate Professor');

-- ─────────────────────────────────────────────
-- STUDENTS
-- ─────────────────────────────────────────────
INSERT INTO students (first_name, last_name, email, phone, dob, gender, dept_id, enrollment_no, join_year, status, address) VALUES
('Aarav',    'Sharma',   'aarav.sharma@student.edu',   '9876543210', '2003-05-14', 'Male',   1, 'CS2021001', 2021, 'Active',   '12 MG Road, Delhi'),
('Priya',    'Patel',    'priya.patel@student.edu',    '9876543211', '2003-08-22', 'Female', 1, 'CS2021002', 2021, 'Active',   '45 Park Street, Mumbai'),
('Rohan',    'Gupta',    'rohan.gupta@student.edu',    '9876543212', '2002-12-01', 'Male',   1, 'CS2020001', 2020, 'Active',   '78 Hill View, Pune'),
('Sneha',    'Reddy',    'sneha.reddy@student.edu',    '9876543213', '2003-03-19', 'Female', 2, 'ECE2021001',2021, 'Active',   '22 Anna Nagar, Chennai'),
('Vikram',   'Singh',    'vikram.singh@student.edu',   '9876543214', '2002-07-30', 'Male',   2, 'ECE2020001',2020, 'Active',   '89 Civil Lines, Lucknow'),
('Ananya',   'Joshi',    'ananya.joshi@student.edu',   '9876543215', '2003-11-05', 'Female', 1, 'CS2021003', 2021, 'Active',   '34 Baner Rd, Pune'),
('Kiran',    'Nair',     'kiran.nair@student.edu',     '9876543216', '2001-06-15', 'Male',   3, 'ME2019001', 2019, 'Graduated','10 Marine Drive, Kochi'),
('Divya',    'Menon',    'divya.menon@student.edu',    '9876543217', '2003-02-28', 'Female', 5, 'IT2021001', 2021, 'Active',   '56 Jubilee Hills, Hyderabad'),
('Arjun',    'Kapoor',   'arjun.kapoor@student.edu',   '9876543218', '2002-09-17', 'Male',   1, 'CS2020002', 2020, 'Active',   '67 Connaught Place, Delhi'),
('Ishaan',   'Malhotra', 'ishaan.malhotra@student.edu','9876543219', '2003-01-25', 'Male',   4, 'CV2021001', 2021, 'Active',   '23 Salt Lake, Kolkata');

-- ─────────────────────────────────────────────
-- ENROLLMENTS
-- ─────────────────────────────────────────────
INSERT INTO enrollments (student_id, course_id, teacher_id, enroll_date) VALUES
(1, 1, 1, '2021-07-15'), (1, 2, 2, '2021-07-15'), (1, 5, 2, '2022-01-10'),
(2, 1, 1, '2021-07-15'), (2, 2, 2, '2022-01-10'), (2, 5, 2, '2022-01-10'),
(3, 2, 2, '2020-07-15'), (3, 3, 1, '2021-01-10'), (3, 4, 1, '2022-01-10'),
(4, 6, 3, '2021-07-15'), (4, 7, 3, '2022-01-10'),
(5, 6, 3, '2020-07-15'), (5, 7, 3, '2021-01-10'),
(6, 1, 1, '2021-07-15'), (6, 2, 2, '2022-01-10'),
(8, 10,5, '2021-07-15'),
(9, 3, 1, '2020-07-15'), (9, 4, 1, '2021-07-15'),
(10,9, NULL,'2021-07-15');

-- ─────────────────────────────────────────────
-- GRADES
-- ─────────────────────────────────────────────
INSERT INTO grades (enrollment_id, marks_obtained, exam_date) VALUES
(1, 87.5, '2021-11-20'), (2, 92.0, '2022-05-15'), (3, 76.0, '2022-11-18'),
(4, 65.0, '2021-11-20'), (5, 78.5, '2022-05-15'), (6, 88.0, '2022-11-18'),
(7, 91.0, '2020-11-20'), (8, 55.0, '2021-05-15'), (9, 80.0, '2022-05-15'),
(10,72.0, '2021-11-20'),(11, 68.0, '2022-05-15'),
(12,85.0, '2020-11-20'),(13, 90.0, '2021-05-15'),
(14,95.0, '2021-11-20'),(15, 83.0, '2022-05-15'),
(16,77.0, '2021-11-20'),
(17,62.0, '2020-11-20'),(18, 74.0, '2021-11-20'),
(19,88.5, '2021-11-20');

-- ─────────────────────────────────────────────
-- ATTENDANCE (sample for 3 days)
-- ─────────────────────────────────────────────
INSERT INTO attendance (student_id, course_id, att_date, status) VALUES
(1,1,'2022-01-10','Present'),(1,1,'2022-01-11','Present'),(1,1,'2022-01-12','Absent'),
(2,1,'2022-01-10','Present'),(2,1,'2022-01-11','Late'),   (2,1,'2022-01-12','Present'),
(3,2,'2022-01-10','Absent'), (3,2,'2022-01-11','Present'),(3,2,'2022-01-12','Present'),
(4,6,'2022-01-10','Present'),(4,6,'2022-01-11','Present'),(4,6,'2022-01-12','Present'),
(6,1,'2022-01-10','Present'),(6,1,'2022-01-11','Absent'), (6,1,'2022-01-12','Present');
