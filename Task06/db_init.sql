PRAGMA foreign_keys = ON;

-- Я не уверен кто именно проверяет задание, но отмечу: Я думал добавить атрибут semestr под каждый предмет, но не стал, т.к. его нет в ТЗ

CREATE TABLE Directions (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    field_name TEXT UNIQUE NOT NULL
);

CREATE TABLE Groups (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    direction_id INTEGER NOT NULL,
    group_suffix INTEGER NOT NULL CHECK((group_suffix BETWEEN 0 AND 5) OR (group_suffix BETWEEN 11 AND 13)),
    group_year INTEGER NOT NULL,
    FOREIGN KEY (direction_id) REFERENCES Directions(ID) ON DELETE RESTRICT

    UNIQUE(direction_id, group_year, group_suffix)
);

CREATE TABLE Students (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    group_id INTEGER NOT NULL,
    first_name TEXT NOT NULL,
    second_name TEXT NOT NULL,
    middle_name TEXT,
    birthday TEXT NOT NULL,
    gender TEXT NOT NULL CHECK(gender IN ('female', 'male')),
    FOREIGN KEY (group_id) REFERENCES Groups(ID) ON DELETE RESTRICT
);

CREATE TABLE Curriculum (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    direction_id INTEGER NOT NULL,
    course_name TEXT NOT NULL,
    lecture_hours INTEGER CHECK(lecture_hours >= 0),
    practic_hours INTEGER CHECK(practic_hours >= 0),
    certification_type TEXT NOT NULL CHECK(certification_type in ('exam', 'credit')),
    FOREIGN KEY (direction_id) REFERENCES Directions(ID) ON DELETE CASCADE
);

CREATE TABLE Grades (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    points INTEGER CHECK(points BETWEEN 0 AND 100),
    grade INTEGER CHECK(grade IN (2, 3, 4, 5)),
    is_passed INTEGER CHECK(is_passed IN (0, 1)),

    CHECK (
        grade = CASE 
            WHEN points >= 86 THEN 5
            WHEN points >= 71 THEN 4
            WHEN points >= 51 THEN 3
            ELSE 2
        END
    ),

    CHECK (
        is_passed = CASE 
            WHEN points >= 51 THEN 1
            ELSE 0
        END
    ),

    FOREIGN KEY (student_id) REFERENCES Students(ID) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Curriculum(ID) ON DELETE RESTRICT,
    UNIQUE(student_id, course_id)
);

CREATE TRIGGER trg_validate_grade_insert
BEFORE INSERT ON Grades
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'Для зачёта нужно заполнить is_passe, grade - для экзамена')
    WHERE (SELECT certification_type FROM Curriculum WHERE ID = NEW.course_id) = 'credit'
      AND (NEW.is_passed IS NULL OR NEW.grade IS NOT NULL);

    SELECT RAISE(ABORT, 'Для экзамена нужно заполнить grade, is_passed - для зачёта')
    WHERE (SELECT certification_type FROM Curriculum WHERE ID = NEW.course_id) = 'exam'
      AND (NEW.grade IS NULL OR NEW.is_passed IS NOT NULL);

    SELECT RAISE(ABORT, 'Для студентов этого учебного направления данный предмет не входит')
    WHERE (SELECT g.direction_id FROM Students s JOIN Groups g ON s.group_id = g.ID WHERE s.ID = NEW.student_id)
       != (SELECT direction_id FROM Curriculum WHERE ID = NEW.course_id);
END;

CREATE TRIGGER trg_validate_grade_update
BEFORE UPDATE OF course_id, student_id, grade, is_passed ON Grades
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'Для зачёта нужно заполнить is_passe, grade - для экзамена')
    WHERE (SELECT certification_type FROM Curriculum WHERE ID = NEW.course_id) = 'credit'
      AND (NEW.is_passed IS NULL OR NEW.grade IS NOT NULL);

    SELECT RAISE(ABORT, 'Для экзамена нужно заполнить grade, is_passed - для зачёта')
    WHERE (SELECT certification_type FROM Curriculum WHERE ID = NEW.course_id) = 'exam'
      AND (NEW.grade IS NULL OR NEW.is_passed IS NOT NULL);

    SELECT RAISE(ABORT, 'Для студентов этого учебного направления данный предмет не входит')
    WHERE (SELECT g.direction_id FROM Students s JOIN Groups g ON s.group_id = g.ID WHERE s.ID = NEW.student_id)
       != (SELECT direction_id FROM Curriculum WHERE ID = NEW.course_id);
END;





INSERT INTO Directions (field_name) VALUES 
('Фундаментальная информатика'),
('Прикладная математика'),
('Программная инженерия');

INSERT INTO Groups (direction_id, group_suffix, group_year) VALUES 
(1, 1, 2026),  -- Группа 101
(1, 2, 2025),  -- Группа 202
(2, 3, 2026), -- Группа 103
(3, 4, 2024); -- Группа 304

INSERT INTO Students (group_id, first_name, second_name, middle_name, birthday, gender) VALUES 
(1, 'Роман', 'Кижаев', 'Феодосиевич', '2007-05-15', 'male'),
(1, 'Евгения', 'Чаплина', 'Сергеевна', '2007-08-22', 'female'),
(1, 'Роман', 'Ухов', 'Алексеевич', '2006-11-10', 'male'),
(2, 'Азиза', 'Рустамова', NULL, '2006-03-05', 'female'),
(2, 'Алексей', 'Воронин', 'Романович', '2006-07-19', 'male'),
(3, 'Елена', 'Волкова', 'Игоревна', '2007-02-14', 'female'),
(3, 'Дмитрий', 'Полковников', 'Святогорович', '2007-09-30', 'male'),
(4, 'Сергей', 'Ксенофонтов', 'Сергеевич', '2005-12-12', 'male'),
(4, 'Илья', 'Берман', 'Александрович', '2007-10-08', 'male');

INSERT INTO Curriculum (direction_id, course_name, lecture_hours, practic_hours, certification_type) VALUES 
(1, 'Математический анализ', 36, 36, 'exam'),
(1, 'Программирование на Assembler', 18, 54, 'exam'),
(1, 'Философия', 36, 0, 'credit'),
(1, 'Физическая культура', 0, 72, 'credit'),
(2, 'Математическая логика', 36, 18, 'exam'),
(2, 'Матричный анализ', 18, 36, 'exam'),
(2, 'Математическая статистика', 36, 0, 'credit'),
(3, 'Английский для профессиональной коммуникации', 0, 108, 'exam'),
(3, 'Базы данных', 18, 18, 'credit');

INSERT INTO Grades (student_id, course_id, points, grade, is_passed) VALUES 
(1, 1, 85, 4, NULL),
(1, 2, 92, 5, NULL),
(1, 3, 85, NULL, 1),
(1, 4, 72, NULL, 1),
(2, 1, 95, 5, NULL),
(2, 2, 98, 5, NULL),
(2, 3, 88, NULL, 1),
(2, 4, 93, NULL, 1),
(3, 1, 25, 2, NULL),
(3, 2, 99, 5, NULL),
(3, 3, 45, NULL, 0),
(3, 4, 89, NULL, 1),
(4, 1, 78, 4, NULL),
(4, 2, 70, 3, NULL),
(4, 3, 96, NULL, 1),
(4, 4, 99, NULL, 1),
(5, 2, 88, 5, NULL),
(5, 3, 85, NULL, 1),
(6, 5, 90, 5, NULL),
(6, 6, 85, 4, NULL),
(6, 7, 52, NULL, 1),
(7, 5, 60, 3, NULL),
(7, 7, 91, NULL, 1),
(8, 8, 100, 5, NULL),
(8, 9, 86, NULL, 1),
(9, 8, 90, 5, NULL),
(9, 9, 90, NULL, 1);
