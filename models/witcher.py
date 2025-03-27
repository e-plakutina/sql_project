from sqlalchemy import Column, Integer, String, DateTime
from .base import Base


class Witcher(Base):
    __tablename__ = 'witchers'

    id = Column(Integer, primary_key=True)
    name = Column(String(255), nullable=False)
    school = Column(String(255), nullable=False)
    level = Column(Integer, default=0, nullable=False)
    money = Column(Integer, default=0, nullable=False)
    experience = Column(Integer, default=0, nullable=False)
    created_at = Column(DateTime, nullable=False)

    def __repr__(self):
        return f"<Witcher(name='{self.name}', school='{self.school}', level={self.level})>"