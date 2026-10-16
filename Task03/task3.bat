#!/bin/bash
chcp 65001

sqlite3 movies_rating.db < db_init.sql

echo "1. Составить список фильмов, имеющих хотя бы одну оценку. Список фильмов отсортировать по году выпуска и по названиям. В списке оставить первые 10 фильмов."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT * FROM movies WHERE year IS NOT NULL AND EXISTS (SELECT 1 FROM ratings WHERE ratings.movieId=movies.id) ORDER BY year, title LIMIT 10;"
echo " "

echo "2. Вывести список всех пользователей, фамилии (не имена!) которых начинаются на букву 'A'. Полученный список отсортировать по дате регистрации. В списке оставить первых 5 пользователей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT * FROM users WHERE substr(name, instr(name, ' ') + 1, 1)='A' ORDER BY register_date LIMIT 5;"

echo "3. Написать запрос, возвращающий информацию о рейтингах в более читаемом формате: имя и фамилия эксперта, название фильма, год выпуска, оценка и дата оценки в формате ГГГГ-ММ-ДД. Отсортировать данные по имени эксперта, затем названию фильма и оценке. В списке оставить первые 50 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT u.name, m.title, m.year, rating, strftime('%Y-%m-%d', timestamp, 'unixepoch') FROM ratings JOIN users AS u ON u.id = ratings.userId JOIN movies AS m ON m.id = ratings.movieId ORDER BY u.name, m.title, rating LIMIT 50;"
echo " "

echo "4. Вывести список фильмов с указанием тегов, которые были им присвоены пользователями. Сортировать по году выпуска, затем по названию фильма, затем по тегу. В списке оставить первые 40 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT * FROM movies JOIN tags AS t ON t.movieId = movies.id ORDER BY year, title, t.tag LIMIT 40;"
echo " "

echo "5. Вывести список самых свежих фильмов. В список должны войти все фильмы последнего года выпуска, имеющиеся в базе данных. Запрос должен быть универсальным, не зависящим от исходных данных (нужный год выпуска должен определяться в запросе, а не жестко задаваться)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT * FROM movies WHERE year = (SELECT MAX(year) FROM movies);"
echo " "

echo "6. Найти все комедии, выпущенные после 2000 года, которые понравились мужчинам (оценка не ниже 4.5). Для каждого фильма в этом списке вывести название, год выпуска и количество таких оценок. Результат отсортировать по году выпуска и названию фильма."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT id, title, year, genres, r.average_rating FROM movies JOIN (SELECT m.id AS movie_id, m.title AS m_title, AVG(rating) as average_rating FROM ratings JOIN users as u ON userId = u.id JOIN movies as m ON movieId = m.id WHERE gender = 'male' GROUP BY m.title) AS r ON r.movie_id = id WHERE genres LIKE '%Comedy%' AND year > 2000 AND r.average_rating > 4.5 LIMIT 100;"
echo " "

echo "7. Провести анализ занятий (профессий) пользователей — вывести количество пользователей для каждого рода занятий. Найти самую распространенную и самую редкую профессию посетителей сайта."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT occupation, COUNT(occupation) AS occupation_count FROM users GROUP BY occupation;"
echo " "