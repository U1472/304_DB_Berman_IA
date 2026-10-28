#!/bin/bash
chcp 65001

sqlite3 movies_rating.db < db_init.sql

echo "Найти все пары пользователей, оценивших один и тот же фильм. Устранить дубликаты, проверить отсутствие пар с самим собой. Для каждой пары должны быть указаны имена пользователей и название фильма, который они оценили. В списке оставить первые 100 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT DISTINCT a.name, b.name, c.title FROM ratings AS aratings JOIN ratings AS bratings ON aratings.movieId = bratings.movieId JOIN users AS a ON a.id = aratings.userId JOIN users AS b ON b.id = bratings.userId JOIN movies AS c ON c.id = aratings.movieId WHERE a.id > b.id AND aratings.movieId = bratings.movieId LIMIT 100;"
echo " "

echo "Найти 10 самых свежих оценок от разных пользователей, вывести названия фильмов, имена пользователей, оценку, дату отзыва в формате ГГГГ-ММ-ДД."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT m.title AS movieName, u.name AS userName, r.rating, date(latest.max_ts, 'unixepoch') AS date FROM ratings AS r JOIN (SELECT userId, MAX(timestamp) AS max_ts FROM ratings GROUP BY userId) AS latest ON latest.userId = r.userId AND latest.max_ts = r.timestamp JOIN movies AS m ON m.id = r.movieId JOIN users AS u ON u.id = r.userId ORDER BY latest.max_ts DESC LIMIT 10;"

echo "Вывести в одном списке все фильмы с максимальным средним рейтингом и все фильмы с минимальным средним рейтингом. Общий список отсортировать по году выпуска и названию фильма. В зависимости от рейтинга в колонке "Рекомендуем" для фильмов должно быть написано "Да" или "Нет"."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH r AS (SELECT AVG(rating) AS rating, movieId FROM ratings GROUP BY movieId) SELECT title, CASE WHEN r.rating = (SELECT MAX(rating) FROM r) THEN 'Да' ELSE 'Нет' END AS "Рекомендуем" FROM movies JOIN r ON r.movieId = id WHERE r.rating = (SELECT MAX(rating) FROM r) OR r.rating = (SELECT MIN(rating) FROM r) ORDER BY year, title;"

echo "Вычислить количество оценок и среднюю оценку, которую дали фильмам пользователи-женщины в период с 2010 по 2012 год."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT COUNT(ratings.rating) AS 'Count', AVG(ratings.rating) AS 'Average value' FROM ratings JOIN users ON users.id = ratings.userId WHERE users.gender = 'female' AND unixepoch('2010-01-01') <= timestamp AND timestamp < unixepoch('2013-01-01');"

echo "Составить список фильмов с указанием их средней оценки и места в рейтинге по средней оценке. Полученный список отсортировать по году выпуска и названиям фильмов. В списке оставить первые 20 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT title, avg_rating, RANK() OVER (ORDER BY avg_rating DESC) AS place FROM (SELECT m.id, m.title, m.year, AVG(r.rating) AS avg_rating FROM movies AS m JOIN ratings AS r ON r.movieId = m.id GROUP BY m.id, m.title, m.year) AS t ORDER BY year, title LIMIT 20;"

echo "Вывести список из 10 последних зарегистрированных пользователей в формате "Фамилия Имя|Дата регистрации" (сначала фамилия, потом имя)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT substr(name, instr(name, ' ') + 1, length(name) - instr(name, ' ')) || ' ' || substr(name, 0, instr(name, ' ')) || '|' || register_date FROM users ORDER BY register_date DESC LIMIT 10;"

echo "С помощью рекурсивного CTE составить таблицу умножения для чисел от 1 до 10. Должен получиться один столбец следующего вида:
1x1=1
1x2=2
. . .
1x10=10
2x1=2
2x2=2
. . .
10x9=90
10x10=100"
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE x (firstnum, secondnum, result) AS (VALUES(1, 1, '1x1=1') UNION ALL SELECT IIF (secondnum + 1 > 10, firstnum + 1, firstnum), IIF (secondnum + 1 < 11, secondnum + 1, 1), COALESCE(firstnum, 0) || 'x' || COALESCE(secondnum, 0) || '=' || (COALESCE(firstnum, 0) * COALESCE(secondnum, 0)) FROM x ) SELECT result FROM x LIMIT 100 OFFSET 1;"

echo "С помощью рекурсивного CTE выделить все жанры фильмов, имеющиеся в таблице movies (каждый жанр в отдельной строке)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE x (thisGenre, nextGenres) AS (
SELECT '', group_concat(genres, '|') || '|' FROM movies

UNION ALL

SELECT substr(nextGenres, 0, instr(nextGenres, '|')), substr(nextGenres, instr(nextGenres, '|') + 1) FROM x WHERE instr(nextGenres, '|') > 0)

SELECT thisGenre FROM x;"