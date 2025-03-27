from datetime import datetime

from models import Contract, City
from models.base import Session
from models.monster import Monster
from models.witcher import Witcher


'''Недалеко от Вызимы появился новый монстр, и только подражатель Геральта мог его победить.'''


def main():
    session = Session()

    try:
        witcher = Witcher(
            name="Гервант Возьмак",
            school="Волк",
            level=50,
            money=2000,
            experience=10000,
            created_at=datetime.now()
        )
        session.add(witcher)
        session.flush()

        monster = Monster(
            name="Риггер",
            type="Гибрид",
            danger_level=45,
            location="Канализация",
            weakness={"type": 'Игни', "items": ['Бомба Драконья Кровь']}
        )
        session.add(monster)
        session.flush()

        city = City(
            name="Возьмыма",
            region="Темерия",
            population=3000
        )
        session.add(city)
        session.flush()

        contract = Contract(
            monster_id=monster.id,
            city_id=city.id,
            reward=2800,
            status="Открыт",
            witcher_id=witcher.id,
            created_at=datetime.now()
        )
        session.add(contract)

        session.commit()


        print(f"Created witcher: {witcher}")
        print(f"Created monster: {monster}")
        print(f"Created city: {city}")
        print(f"Created contract: {contract}")
    except Exception as e:
        session.rollback()
        print(f"Error: {e}")
    finally:
        session.close()


if __name__ == "__main__":
    main()

print("End!")