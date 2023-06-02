--Table creation:
CREATE TABLE courses(
    course_id int primary key,
    course_code text,
    course_title text,
    course_credits int
);

CREATE TABLE courses_programs(
    co_pro int primary key,
    program_id int,
    course_id int
);

CREATE TABLE feeder(
    feeder_id int primary key,
    school_name text,
    management text,
    urban_rural text,
    funding text,
    district
)

CREATE TABLE grades(
    grade_id int primary key,
    semester text,
    course_grade text,
    course_points float,
    student_id int,
    course_id int
);

CREATE TABLE programs(
    program_id int,
    program_code text,
    program_name text,
    degree_id int,
    degree text
);

CREATE TABLE student_info(
    student_id int,
    gender text,
    ethnicity text,
    city text,
    district text,
    PROGRAM text,
    DEGREEID text,
    DEGREE text,
    COURSECODE text,
    COURSETITLE text,
    COURSECREDITS int,
    program_start text,
    program_status text,
    programEnd text,
    grad_date text,
    feeder_id int
);

--Copying csv files.
COPY courses
FROM '/home/zhenitsu/Downloads/courses.csv'
DELIMITER ','
CSV HEADER;

COPY courses_programs
FROM '/home/zhenitsu/Downloads/courses_programs.csv'
DELIMITER ','
CSV HEADER;

COPY feeder
FROM '/home/zhenitsu/Downloads/feeder.csv'
DELIMITER ','
CSV HEADER;

COPY grades
FROM '/home/zhenitsu/Downloads/grades.csv'
DELIMITER ','
CSV HEADER;

COPY programs
FROM '/home/zhenitsu/Downloads/programs.csv'
DELIMITER ','
CSV HEADER;

COPY student_info
FROM '/home/zhenitsu/Downloads/student_info.csv'
DELIMITER ','
CSV HEADER;

--Query Time.
--Find the total number of students and average course points by feeder institutions.
SELECT F.school_name, 
COUNT(DISTINCT SI.student_id) AS amount,
AVG(CAST(G.course_points AS float)) AS average
FROM feeder AS F
JOIN student_info  AS SI 
ON F.feeder_id = SI.feeder_id
JOIN grades AS G 
ON SI.student_id = G.student_id
GROUP BY F.school_name;

--Find the total number of students and average course points by gender.
SELECT SI.gender AS gender,
COUNT(SI.student_id) as amount,
AVG(CAST(G.course_points as float)) as average
FROM student_info AS SI
JOIN Grades AS G
ON SI.student_id = G.student_id
GROUP BY SI.gender;

--Find the total number of students and average course points by ethnicity.
SELECT SI.ethnicity AS ethnicity,
COUNT(SI.student_id) AS amount,
AVG(CAST(G.course_points AS FLOAT)) AS average
FROM student_info AS SI
JOIN grades AS G 
on SI.student_id = G.student_id
GROUP BY SI.ethnicity;

--Find the total number of students and average course points by city.
SELECT SI.city,
COUNT(SI.student_id) AS amount,
AVG(CAST(G.course_points AS FLOAT)) AS average
FROM student_info AS SI
JOIN grades AS G 
ON SI.student_id = G.student_id
GROUP BY SI.city;

--Find the total number of students and average course points by district.
SELECT SI.district AS district,
COUNT(SI.student_id) AS students,
AVG(CAST(G.course_points AS FLOAT)) AS average
FROM student_info AS SI
JOIN grades AS G 
on SI.student_id = G.student_id
GROUP BY SI.district;

--Find the total number and percentage of students by program status.
SELECT program_status AS status,
COUNT(student_id) AS students,
(COUNT(student_id)*100.0)/(SELECT COUNT(*) FROM student_info ) AS percentage
FROM student_info 
GROUP BY program_status;

--Find the letter grade breakdown (how many A, A-,B,B+,...)for each of the following courses: FoC, Prog 1, Algebra, Trig, College English I 
SELECT C.course_title,
COUNT(CASE
WHEN G.course_grade = 'A' THEN 4.0
WHEN G.course_grade = 'A-' THEN 3.7
WHEN G.course_grade = 'B+' THEN 3.3
WHEN G.course_grade = 'B' THEN 3.0
WHEN G.course_grade = 'B-' THEN 2.7
WHEN G.course_grade = 'C+' THEN 2.3
WHEN G.course_grade = 'C' THEN 2.0
WHEN G.course_grade = 'C+' THEN 2.3
WHEN G.course_grade = 'C' THEN 2.0
WHEN G.course_grade = 'C-' THEN 1.7
WHEN G.course_grade = 'D+' THEN 1.3
WHEN G.course_grade = 'D' THEN 1.0
WHEN G.course_grade = 'F' THEN 0.0
ELSE NULL
END) AS amount
FROM courses AS C
JOIN grades AS G 
ON C.course_id = G.course_id
WHERE C.course_title IN  ('FUNDAMENTALS OF COMPUTING', 'PRINCIPLES OF PROGRAMMING I', 'PRINCIPLES OF PROGRAMMING II',
'ALGEBRA', 'TRIGONOMETRY', 'COLLEGE ENGLISH I')
GROUP BY C.course_title;

--My Queries.
--Graduated from AINT
SELECT program_status AS status,
COUNT (DISTINCT student_id) AS amount
FROM student_info
WHERE program_status = 'Graduated'
AND program_code = 'AINT'
GROUP BY student_info.program_status;

--Amount of students whose ethnicity is Creole, Garifuna or Mestizo.
SELECT ethnicity, 
COUNT(student_id) AS amount
FROM student_info
WHERE ethnicity = 'Creole'
OR ethnicity = 'Mestizo'
OR ethnicity = 'Garifuna'
GROUP BY student_info.ethnicity;

--Students that came from Muffles Jr.
SELECT SI.student_id, F.school_name
FROM student_info AS SI
JOIN feeder AS F
ON SI.feeder_id = F.feeder_id
WHERE SI.feeder_id = '4'
AND F.feeder_id = '4';
--That is crazy that there no student from Muffles Jr.

SELECT student_id, program_status, program_code
FROM student_info
WHERE program_status = 'Graduated'
AND program_code = 'AINT'
GROUP BY student_id;

--Number of Females in AINT.
SELECT COUNT(gender) AS amount
FROM student_info
WHERE gender = 'F'
AND program_code = 'AINT';

--Courses with CMPS in their code.
SELECT course_code, course_title, course_credits
FROM courses
WHERE course_code LIKE 'CMPS%';

--Students that got an A, A+, A-.
SELECT SI.student_id, C.course_title AS course_name, G.course_grade
FROM student_info AS SI
JOIN grades AS G
ON SI.student_id = G.student_id
JOIN courses AS C
ON G.course_id = C.course_id
WHERE G.course_grade LIKE 'A%';

--Students that came from Sacred Heart and graduated
SELECT SI.student_id, F.school_name, SI.program_status
FROM student_info AS SI
JOIN feeder AS F 
ON SI.feeder_id = F.feeder_id
WHERE F.feeder_id = '40'
AND SI.program_status = 'Graduated';

--Students that are from the rural areas.
SELECT SI.student_id, F.urban_rural, F.school_name, F.management
FROM student_info AS SI
JOIN feeder AS F
ON SI.feeder_id = F.feeder_id
WHERE F.urban_rural = 'R';

--Amounts of Students that have dropped or been terminated.
SELECT program_status,
COUNT (program_status) AS amount
FROM student_info
WHERE program_status IN ('Dropped', 'Terminated')
GROUP BY program_status;