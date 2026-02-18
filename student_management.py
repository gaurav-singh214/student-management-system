"""
============================================================
  STUDENT MANAGEMENT SYSTEM - Python Interface
  File: student_management.py
  Description: Python menu-driven CLI app using MySQL
  Requirements: pip install mysql-connector-python
============================================================
"""

import mysql.connector
from mysql.connector import Error
from datetime import date

# ──────────────────────────────────────────────
#  DATABASE CONNECTION
# ──────────────────────────────────────────────
DB_CONFIG = {
    "host":     "localhost",
    "user":     "root",       # ← change to your MySQL username
    "password": "your_pass",  # ← change to your MySQL password
    "database": "student_management"
}

def get_connection():
    """Create and return a MySQL connection."""
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except Error as e:
        print(f"  [ERROR] Cannot connect to database: {e}")
        return None


# ──────────────────────────────────────────────
#  STUDENT OPERATIONS
# ──────────────────────────────────────────────

def add_student():
    """CREATE: Add a new student."""
    print("\n  ── Add New Student ──")
    first     = input("  First name      : ").strip()
    last      = input("  Last name       : ").strip()
    email     = input("  Email           : ").strip()
    phone     = input("  Phone           : ").strip()
    dob       = input("  DOB (YYYY-MM-DD): ").strip()
    gender    = input("  Gender (Male/Female/Other): ").strip()
    dept_id   = int(input("  Dept ID         : "))
    enroll_no = input("  Enrollment No   : ").strip()
    join_year = int(input("  Join Year       : "))
    address   = input("  Address         : ").strip()

    sql = """
        INSERT INTO students
            (first_name, last_name, email, phone, dob, gender,
             dept_id, enrollment_no, join_year, address)
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
    """
    conn = get_connection()
    if not conn:
        return
    try:
        cur = conn.cursor()
        cur.execute(sql, (first, last, email, phone, dob, gender,
                          dept_id, enroll_no, join_year, address))
        conn.commit()
        print(f"  ✓ Student '{first} {last}' added (ID: {cur.lastrowid})")
    except Error as e:
        print(f"  [ERROR] {e}")
    finally:
        conn.close()


def view_all_students():
    """READ: Display all active students."""
    sql = """
        SELECT s.student_id,
               CONCAT(s.first_name,' ',s.last_name) AS name,
               s.enrollment_no, d.dept_name,
               s.join_year, s.status
        FROM students s
        JOIN departments d ON s.dept_id = d.dept_id
        ORDER BY s.student_id
    """
    conn = get_connection()
    if not conn:
        return
    try:
        cur = conn.cursor()
        cur.execute(sql)
        rows = cur.fetchall()
        print(f"\n  {'ID':<5} {'Name':<22} {'Enroll No':<14} {'Dept':<25} {'Year':<6} {'Status'}")
        print("  " + "─" * 85)
        for r in rows:
            print(f"  {r[0]:<5} {r[1]:<22} {r[2]:<14} {r[3]:<25} {r[4]:<6} {r[5]}")
        print(f"  Total: {len(rows)} record(s)")
    except Error as e:
        print(f"  [ERROR] {e}")
    finally:
        conn.close()


def search_student():
    """READ: Search student by name or enrollment number."""
    term = input("\n  Search (name or enrollment no): ").strip()
    sql = """
        SELECT s.student_id,
               CONCAT(s.first_name,' ',s.last_name) AS name,
               s.enrollment_no, s.email, s.phone,
               d.dept_name, s.status
        FROM students s
        JOIN departments d ON s.dept_id = d.dept_id
        WHERE s.first_name  LIKE %s
           OR s.last_name   LIKE %s
           OR s.enrollment_no = %s
    """
    like = f"%{term}%"
    conn = get_connection()
    if not conn:
        return
    try:
        cur = conn.cursor()
        cur.execute(sql, (like, like, term))
        rows = cur.fetchall()
        if not rows:
            print("  No students found.")
            return
        for r in rows:
            print(f"\n  ID         : {r[0]}")
            print(f"  Name       : {r[1]}")
            print(f"  Enroll No  : {r[2]}")
            print(f"  Email      : {r[3]}")
            print(f"  Phone      : {r[4]}")
            print(f"  Department : {r[5]}")
            print(f"  Status     : {r[6]}")
    except Error as e:
        print(f"  [ERROR] {e}")
    finally:
        conn.close()


def update_student():
    """UPDATE: Update a student's phone and address."""
    student_id = int(input("\n  Enter Student ID to update: "))
    phone   = input("  New phone   : ").strip()
    address = input("  New address : ").strip()

    sql = "UPDATE students SET phone=%s, address=%s, updated_at=NOW() WHERE student_id=%s"
    conn = get_connection()
    if not conn:
        return
    try:
        cur = conn.cursor()
        cur.execute(sql, (phone, address, student_id))
        conn.commit()
        print(f"  ✓ Student ID {student_id} updated ({cur.rowcount} row(s))")
    except Error as e:
        print(f"  [ERROR] {e}")
    finally:
        conn.close()


def delete_student():
    """DELETE: Soft-delete (mark as Dropped) or hard delete."""
    student_id = int(input("\n  Enter Student ID to delete: "))
    choice = input("  (S)oft delete [Dropped] or (H)ard delete? ").strip().upper()

    conn = get_connection()
    if not conn:
        return
    try:
        cur = conn.cursor()
        if choice == 'S':
            cur.execute("UPDATE students SET status='Dropped' WHERE student_id=%s", (student_id,))
            conn.commit()
            print(f"  ✓ Student ID {student_id} marked as Dropped.")
        elif choice == 'H':
            confirm = input("  ⚠ This is permanent. Type YES to confirm: ")
            if confirm == 'YES':
                cur.execute("DELETE FROM students WHERE student_id=%s", (student_id,))
                conn.commit()
                print(f"  ✓ Student ID {student_id} permanently deleted.")
            else:
                print("  Cancelled.")
        else:
            print("  Invalid choice.")
    except Error as e:
        print(f"  [ERROR] {e}")
    finally:
        conn.close()


def view_report_card():
    """READ: Show a student's courses and grades."""
    student_id = int(input("\n  Enter Student ID: "))
    sql = """
        SELECT c.course_name, c.course_code, c.credits, c.semester,
               IFNULL(g.marks_obtained,'—')   AS marks,
               IFNULL(g.grade_letter,'—')     AS grade,
               IFNULL(g.grade_point,'—')      AS gp
        FROM enrollments e
        JOIN courses c ON e.course_id = c.course_id
        LEFT JOIN grades g ON e.enrollment_id = g.enrollment_id
        WHERE e.student_id = %s
        ORDER BY c.semester, c.course_name
    """
    cgpa_sql = """
        SELECT ROUND(SUM(g.grade_point*c.credits)/SUM(c.credits),2)
        FROM enrollments e
        JOIN courses c ON e.course_id=c.course_id
        JOIN grades  g ON e.enrollment_id=g.enrollment_id
        WHERE e.student_id=%s
    """
    conn = get_connection()
    if not conn:
        return
    try:
        cur = conn.cursor()
        cur.execute(sql, (student_id,))
        rows = cur.fetchall()
        if not rows:
            print("  No records found.")
            return
        print(f"\n  {'Course':<35} {'Code':<10} {'Cr':<4} {'Sem':<5} {'Marks':<8} {'Grd':<5} {'GP'}")
        print("  " + "─" * 75)
        for r in rows:
            print(f"  {r[0]:<35} {r[1]:<10} {r[2]:<4} {r[3]:<5} {str(r[4]):<8} {str(r[5]):<5} {r[6]}")
        cur.execute(cgpa_sql, (student_id,))
        cgpa = cur.fetchone()[0]
        print(f"\n  CGPA: {cgpa if cgpa else '—'}")
    except Error as e:
        print(f"  [ERROR] {e}")
    finally:
        conn.close()


# ──────────────────────────────────────────────
#  MAIN MENU
# ──────────────────────────────────────────────

def main_menu():
    menu = """
  ╔══════════════════════════════════════════╗
  ║     STUDENT MANAGEMENT SYSTEM (SMS)     ║
  ╠══════════════════════════════════════════╣
  ║  1. Add New Student                     ║
  ║  2. View All Students                   ║
  ║  3. Search Student                      ║
  ║  4. Update Student Info                 ║
  ║  5. Delete Student                      ║
  ║  6. View Report Card                    ║
  ║  0. Exit                                ║
  ╚══════════════════════════════════════════╝
"""
    while True:
        print(menu)
        choice = input("  Enter choice: ").strip()
        if   choice == '1': add_student()
        elif choice == '2': view_all_students()
        elif choice == '3': search_student()
        elif choice == '4': update_student()
        elif choice == '5': delete_student()
        elif choice == '6': view_report_card()
        elif choice == '0':
            print("\n  Goodbye!\n")
            break
        else:
            print("  Invalid option, try again.")


if __name__ == "__main__":
    main_menu()
