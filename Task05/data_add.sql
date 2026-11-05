BEGIN TRANSACTION;

-- Верные данные моих одногруппников у меня отсутствуют. Представим, что они соответствуют тому, что прописано в инсертах сейчас
INSERT INTO users (id, first_name, second_name, email, gender, register_date, occupationId) VALUES
(NULL, 'Илья', 'Берман', 'berman@mail.com', 'male', (SELECT id FROM occupations WHERE occupation = 'student')),
(NULL, 'Анастасия', 'Байол', 'bayol@mail.com', 'female', (SELECT id FROM occupations WHERE occupation = 'student')),
(NULL, 'Максим', 'Башмаков', 'bashmakov@mail.com', 'male', (SELECT id FROM occupations WHERE occupation = 'student')),
(NULL, 'Глеб', 'Вельдяскин', 'veldyaskin@mail.com', 'male', (SELECT id FROM occupations WHERE occupation = 'student')),
(NULL, 'Алексей', 'Воронин', 'voronin@mail.com', 'male', (SELECT id FROM occupations WHERE occupation = 'student'));

INSERT INTO movies (title, year) VALUES 
('Analyze This', 1999),
('Analyze That', 2002),
('Now You See Me', 2013);

INSERT INTO movie_genres (movieId, genreId) VALUES 
((SELECT id FROM movies WHERE title = 'Analyze This'), (SELECT id FROM genres WHERE genre = 'Comedy')),
((SELECT id FROM movies WHERE title = 'Analyze That'), (SELECT id FROM genres WHERE genre = 'Crime')),
((SELECT id FROM movies WHERE title = 'Now You See Me'), (SELECT id FROM genres WHERE genre = 'Thriller'));

INSERT INTO ratings (userId, movieId, rating, timestamp) VALUES 
(
    (SELECT id FROM users WHERE email = 'berman@mail.com'), 
    (SELECT id FROM movies WHERE title = 'Analyze This'), 
    5.0, 
    '2018-11-06 21:06:03'
),
(
    (SELECT id FROM users WHERE email = 'berman@mail.com'), 
    (SELECT id FROM movies WHERE title = 'Analyze That'), 
    5.0, 
    '2018-07-26 18:41:25'
),
(
    (SELECT id FROM users WHERE email = 'berman@mail.com'), 
    (SELECT id FROM movies WHERE title = 'Now You See Me'), 
    3.0, 
    '2018-05-01 13:17:06'
);

COMMIT;
