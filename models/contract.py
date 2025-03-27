# models/contract.py
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from .base import Base


class Contract(Base):
    __tablename__ = 'contracts'

    id = Column(Integer, primary_key=True)
    monster_id = Column(Integer, ForeignKey('monsters.id'), nullable=False)
    city_id = Column(Integer, ForeignKey('cities.id'), nullable=False)
    reward = Column(Integer, default=0, nullable=False)
    status = Column(String(255), nullable=False)
    witcher_id = Column(Integer, ForeignKey('witchers.id'), nullable=False)
    created_at = Column(DateTime, nullable=False)

    def __repr__(self):
        return f"<Contract(reward={self.reward}, status='{self.status}')>"