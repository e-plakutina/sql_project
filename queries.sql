-- История, как Геральт победил непонятное чудовище, появившееся в округе Каэр Трольде. Другой же ведьмак, не сумевший выполнить заказ, покинул Гильдию

CALL create_monster('Хим', 'Призраки', 25, 'Людские поселения', Null);

CALL learn_alchemy_recipe(1, 10);

CALL create_and_complete_contract(12, 23, 7, 3000);

CALL create_and_complete_contract(1, 23, 7, 3500);


-- Также Геральт выучил новый рецепт

CALL add_alchemy('Масло против призраков', 'Увеличивает урон против призраков', '["Медвежье сало", "Лепестки гинации"]');

-- Теперь у монстра известна уязвимость
UPDATE monsters
SET weakness = '["Масло против призраков"]'
ORDER BY id DESC
LIMIT 1;

UPDATE monsters
SET weakness = JSON_ARRAY_APPEND(weakness, '$', 'Игни')
ORDER BY id DESC
LIMIT 1;


# DELETE FROM witcher_alchemy
# WHERE witcher_id = 1 AND alchemy_id = 16;

CALL learn_alchemy_recipe(1, 16);


-- Выведем информацию о ведьмаке (Геральте), монстре, городе и номере контракта, который выполнил ведьмак
SELECT contracts.id,
       witchers.name AS witcher_name,
       monsters.name AS monster_name,
       cities.name AS city_name
FROM contracts, monsters, cities, witchers
WHERE contracts.monster_id = monsters.id
  AND contracts.city_id = cities.id
  AND contracts.witcher_id = witchers.id
  AND contracts.witcher_id = 1
  AND contracts.status = 'Выполнен';


-- Найдем ведьмаков, у которых количество выполненных контрактов выше среднего
SELECT witchers.name,
       (SELECT COUNT(*)
        FROM contracts
        WHERE contracts.witcher_id = witchers.id AND contracts.status = 'Выполнен') AS completed_contracts
FROM witchers
WHERE (SELECT COUNT(*)
       FROM contracts
       WHERE contracts.witcher_id = witchers.id AND contracts.status = 'Выполнен') >
      (SELECT AVG(contract_count)
       FROM (SELECT COUNT(*) AS contract_count
             FROM contracts
             WHERE status = 'Выполнен'
             GROUP BY witcher_id) AS avg_counts);



-- Выведем ведьмаков, у которых суммарный урон выше среднего урона
SELECT witchers.name AS witcher_name, SUM(equipment.damage) AS total_damage
FROM witchers
JOIN equipment ON witchers.id = equipment.witcher_id
GROUP BY witchers.id, witchers.name
HAVING SUM(equipment.damage) > (
    SELECT AVG(total_damage)
    FROM (
        SELECT SUM(equipment.damage) AS total_damage
        FROM witchers
        JOIN equipment ON witchers.id = equipment.witcher_id
        GROUP BY witchers.id
    ) AS avg_damage_subquery
);



-- Выведем статистику по чудовищам (самые опасные, упоминающиеся в контрактах, средняя награда за них)
WITH monster_contract_stats AS (
    SELECT monsters.id, monsters.name, monsters.danger_level,
           COUNT(contracts.id) AS contract_count,
           AVG(contracts.reward) AS avg_reward
    FROM monsters
    LEFT JOIN contracts ON monsters.id = contracts.monster_id
    GROUP BY monsters.id, monsters.name, monsters.danger_level
)
SELECT name, danger_level, contract_count, avg_reward
FROM monster_contract_stats
WHERE danger_level > 5 AND contract_count > 0
ORDER BY danger_level DESC;


-- Оконные функции:

-- Выведем еще топ-1 самых опасных чудовищ в каждом регионе
SELECT
    ranked_monsters.monster,
    ranked_monsters.region,
    ranked_monsters.danger_level
FROM (
    SELECT
        monsters.name AS monster,
        cities.region,
        monsters.danger_level,
        DENSE_RANK() OVER (PARTITION BY cities.region ORDER BY monsters.danger_level DESC) AS danger_rank_in_region
    FROM monsters
    JOIN contracts ON monsters.id = contracts.monster_id
    JOIN cities ON contracts.city_id = cities.id
) AS ranked_monsters
WHERE ranked_monsters.danger_rank_in_region = 1;


-- Выведем статистику по каждой школе ведьмаков (общая награда по школе, общая награда всех школ, средняя награда среди всех школ)
SELECT
    witchers.school AS witcher_school,
    SUM(contracts.reward) AS total_reward_per_school,
    SUM(SUM(contracts.reward)) OVER () AS total_global_reward,
    AVG(SUM(contracts.reward)) OVER () AS avg_reward_per_school
FROM witchers
LEFT JOIN contracts ON witchers.id = contracts.witcher_id
GROUP BY witchers.school;