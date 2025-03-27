# models/__init__.py
from sqlalchemy.orm import relationship

from .base import Base, engine, Session
from .witcher import Witcher
from .monster import Monster
from .contract import Contract
from .city import City


# Устанавливаем связи после того как все модели загружены
def setup_relationships():
    # Witcher relationships
    # Witcher.equipment = relationship("Equipment", back_populates="witcher")
    Witcher.contracts = relationship("Contract", back_populates="witcher")

    # Monster relationships
    Monster.contracts = relationship("Contract", back_populates="monster")

    Contract.monster = relationship("Monster", back_populates="contracts")
    Contract.witcher = relationship("Witcher", back_populates="contracts")
    Contract.city = relationship("City", back_populates="contracts")

    City.contracts = relationship("Contract", back_populates="city")


# Вызываем функцию установки связей
setup_relationships()

__all__ = [
    'Witcher', 'Monster', 'Contract', 'City'
]