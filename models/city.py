# models/city.py
from sqlalchemy import Column, Integer, String
from .base import Base

class City(Base):
    __tablename__ = 'cities'

    id = Column(Integer, primary_key=True)
    name = Column(String(255), nullable=False)
    region = Column(String(255), nullable=False)
    population = Column(Integer, nullable=False)

    def __repr__(self):
        return f"<City(name='{self.name}', region='{self.region}')>"