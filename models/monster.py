from sqlalchemy import Column, Integer, String, JSON

from .base import Base


class Monster(Base):
    __tablename__ = 'monsters'

    id = Column(Integer, primary_key=True)
    name = Column(String(255), nullable=False)
    type = Column(String(255), nullable=False)
    danger_level = Column(Integer, nullable=False)
    location = Column(String(255), nullable=False)
    weakness = Column(JSON, nullable=True)

    def __repr__(self):
        return f"<Monster(name='{self.name}', type='{self.type}', danger={self.danger_level})>"