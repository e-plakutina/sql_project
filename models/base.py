# models/base.py
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

Base = declarative_base()

# Настройка подключения к БД
DB_USER = "root"
DB_PASSWORD = "root"
DB_HOST = "db"
DB_PORT = "3306"
DB_NAME = "witcher"

DATABASE_URL = f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}" # mysql+pymysql://root:root@db:3306/witcher

engine = create_engine(DATABASE_URL)

Session = sessionmaker(bind=engine)
session = Session()
