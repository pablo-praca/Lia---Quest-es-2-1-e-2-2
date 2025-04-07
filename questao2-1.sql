CREATE TABLE schools (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE courses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    school_id INTEGER NOT NULL REFERENCES schools(id),
    CONSTRAINT valid_course_name CHECK (name <> '')
);

CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    enrolled_at DATE NOT NULL DEFAULT CURRENT_DATE,
    course_id INTEGER NOT NULL REFERENCES courses(id),
    CONSTRAINT valid_student_name CHECK (name <> '')
);

CREATE INDEX idx_courses_name ON courses(name);
CREATE INDEX idx_students_course_id ON students(course_id);
CREATE INDEX idx_students_enrolled_at ON students(enrolled_at);


INSERT INTO schools (name) VALUES
('Data Science Academy'),
('Tech Institute'),
('Digital University'),
('AI College'),
('Coding School'),
('Business Analytics Institute'),
('Machine Learning University'),
('Cloud Computing College'),
('Big Data School'),
('Information Technology Institute');


INSERT INTO courses (name, price, school_id) VALUES
('Data Analysis Fundamentals', 1200.00, 1),
('Data Engineering', 1500.00, 1),
('Python Programming', 1000.00, 2),
('Data Visualization', 1300.00, 3),
('Database Design', 1100.00, 4),
('Data Science Bootcamp', 2000.00, 5),
('Web Development', 900.00, 6),
('Data Mining', 1600.00, 7),
('Cloud Architecture', 1800.00, 8),
('Data Structures', 950.00, 9);


INSERT INTO students (name, enrolled_at, course_id) VALUES
('Ana Silva', '2023-01-15', 1),
('Bruno Costa', '2023-01-15', 1),
('Carlos Oliveira', '2023-01-16', 2),
('Daniela Souza', '2023-01-16', 2),
('Eduardo Lima', '2023-01-16', 4),
('Fernanda Rocha', '2023-01-17', 6),
('Gustavo Santos', '2023-01-18', 6),
('Helena Ferreira', '2023-01-18', 8),
('Igor Almeida', '2023-01-19', 8),
('Juliana Martins', '2023-01-20', 10),
('Lucas Pereira', '2023-01-20', 4),
('Mariana Gomes', '2023-01-21', 6),
('Nicolas Ribeiro', '2023-01-22', 2),
('Patricia Lopes', '2023-01-23', 8),
('Rafael Cunha', '2023-01-24', 10);

-- Questão 2-1-a

SELECT 
    s.name AS school_name,
    st.enrolled_at AS enrollment_date,
    COUNT(st.id) AS enrolled_students,
    SUM(c.price) AS total_revenue
FROM 
    students st
INNER JOIN 
    courses c ON st.course_id = c.id
INNER JOIN 
    schools s ON c.school_id = s.id
WHERE 
    c.name LIKE 'Data%'
GROUP BY 
    s.name, 
    st.enrolled_at
ORDER BY 
    st.enrolled_at DESC;

-- Questão 2-1-b

WITH daily_enrollments AS (
    SELECT 
        s.name AS school_name,
        st.enrolled_at AS enrollment_date,
        COUNT(*) AS daily_students
    FROM students st
    JOIN courses c ON st.course_id = c.id
    JOIN schools s ON c.school_id = s.id
    WHERE c.name LIKE 'Data%'
    GROUP BY s.name, st.enrolled_at
)
SELECT 
    school_name,
    enrollment_date,
    daily_students,
    SUM(daily_students) OVER w AS cumulative_students,
    ROUND(AVG(daily_students) OVER (w ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS moving_avg_7_days,
    ROUND(AVG(daily_students) OVER (w ROWS BETWEEN 29 PRECEDING AND CURRENT ROW), 2) AS moving_avg_30_days
FROM daily_enrollments
WINDOW w AS (PARTITION BY school_name ORDER BY enrollment_date)
ORDER BY school_name, enrollment_date DESC;

WITH matriculas_diarias AS (
    SELECT 
        s.name AS escola,
        st.enrolled_at AS data_matricula,
        COUNT(*) AS alunos_dia
    FROM students st
    JOIN courses c ON st.course_id = c.id
    JOIN schools s ON c.school_id = s.id
    WHERE c.name LIKE 'Data%'
    GROUP BY s.name, st.enrolled_at
)
SELECT 
    escola,
    data_matricula,
    alunos_dia,
    SUM(alunos_dia) OVER (PARTITION BY escola ORDER BY data_matricula) AS acumulado_alunos,
    ROUND(AVG(alunos_dia) OVER (
        PARTITION BY escola 
        ORDER BY data_matricula
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS media_7dias,
    ROUND(AVG(alunos_dia) OVER (
        PARTITION BY escola 
        ORDER BY data_matricula
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ), 2) AS media_30dias
FROM matriculas_diarias
ORDER BY escola, data_matricula DESC;