@echo off
py make_db_init.py
sqlite3 movies_ratings.db < db_init.sql