-- Создание заказа и начало битвы (два сценария: победа или поражение в зависимости от уровня ведьмака и уровня чудовища)
DELIMITER //

CREATE PROCEDURE create_and_complete_contract(
    IN p_witcher_id INT,
    IN p_monster_id INT,
    IN p_city_id INT,
    IN p_reward INT
)
BEGIN
    DECLARE contract_id INT;
    DECLARE witcher_level INT;
    DECLARE monster_level INT;

    -- Получаем уровень ведьмака
    SELECT level INTO witcher_level FROM witchers WHERE id = p_witcher_id;

    -- Получаем уровень опасности монстра
    SELECT danger_level INTO monster_level FROM monsters WHERE id = p_monster_id;

    -- Если ведьмак сильнее или равен по уровню, он побеждает
    IF witcher_level >= monster_level THEN
        -- Создаём контракт
        INSERT INTO contracts (monster_id, city_id, reward, status, witcher_id, created_at)
        VALUES (p_monster_id, p_city_id, p_reward, 'В процессе', p_witcher_id, NOW());

        SET contract_id = LAST_INSERT_ID();

        -- Записываем победу в битвах
        INSERT INTO battles (witcher_id, monster_id, outcome, date)
        VALUES (p_witcher_id, p_monster_id, 'Победа', NOW());

        -- Вывод информации о завершённом контракте
        SELECT c.id         AS contract_id,
               w.name       AS witcher_name,
               m.name       AS monster_name,
               c.reward     AS contract_reward,
               w.money      AS witcher_balance,
               w.level      AS witcher_level,
               w.experience AS witcher_experience
        FROM contracts c
                 JOIN witchers w ON c.witcher_id = w.id
                 JOIN monsters m ON c.monster_id = m.id
        WHERE c.id = contract_id;

    ELSE
        START TRANSACTION;
        -- Ведьмак проигрывает, записываем поражение
        INSERT INTO battles (witcher_id, monster_id, outcome, date)
        VALUES (p_witcher_id, p_monster_id, 'Поражение', NOW());

        -- Удаляем все связанные с ведьмаком записи
        DELETE FROM witcher_alchemy WHERE witcher_id = p_witcher_id;
        DELETE FROM equipment WHERE witcher_id = p_witcher_id;
        DELETE FROM contracts WHERE witcher_id = p_witcher_id;
        DELETE FROM battles WHERE witcher_id = p_witcher_id;

        -- Удаляем самого ведьмака
        DELETE FROM witchers WHERE id = p_witcher_id;
        COMMIT;
    END IF;
END //

DELIMITER ;


-- Создание монстра
DELIMITER //

CREATE PROCEDURE create_monster(
    IN p_name VARCHAR(255),
    IN p_type VARCHAR(255),
    IN p_danger_level INT,
    IN p_location VARCHAR(255),
    IN p_weakness JSON
)
BEGIN
    INSERT INTO monsters (name, type, danger_level, location, weakness)
    VALUES (p_name, p_type, p_danger_level, p_location, p_weakness);

    -- Вывод информации о созданном монстре
    SELECT * FROM monsters WHERE id = LAST_INSERT_ID();
END //

DELIMITER ;


-- Добавление нового рецепта
DELIMITER //

CREATE PROCEDURE add_alchemy(
    IN p_name VARCHAR(255),
    IN p_effect VARCHAR(255),
    IN p_required_ingredients JSON
)
BEGIN
    INSERT INTO alchemy (name, effect, required_ingridients)
    VALUES (p_name, p_effect, p_required_ingredients);

    SELECT * FROM alchemy WHERE id = LAST_INSERT_ID();
END //

DELIMITER ;


DROP PROCEDURE IF EXISTS learn_alchemy_recipe;

-- Ведьмак изучил новый рецепт
DELIMITER //

CREATE PROCEDURE learn_alchemy_recipe(
    IN p_witcher_id INT,
    IN p_alchemy_id INT
)
BEGIN
    -- Проверяем, знает ли ведьмак уже этот рецепт
    IF NOT EXISTS (SELECT 1
                   FROM witcher_alchemy
                   WHERE witcher_id = p_witcher_id
                     AND alchemy_id = p_alchemy_id) THEN
        -- Если не знает, добавляем новый рецепт
        INSERT INTO witcher_alchemy (witcher_id, alchemy_id)
        VALUES (p_witcher_id, p_alchemy_id);

        -- Выводим информацию о рецепте, ведьмаке и монстре
        SELECT (SELECT name FROM alchemy WHERE id = p_alchemy_id)  AS recipe_name,
               (SELECT name FROM witchers WHERE id = p_witcher_id) AS witcher_name,
               (SELECT GROUP_CONCAT(name SEPARATOR ', ')
                FROM monsters
                WHERE JSON_CONTAINS(weakness, CONCAT('"', (SELECT name FROM alchemy WHERE id = p_alchemy_id), '"'),
                                    '$'))
                                                                   AS monster_names;

    ELSE
        -- Если рецепт уже есть, выводим сообщение
        SELECT 'Ведьмак уже знает этот рецепт' AS message;
    END IF;
END //

DELIMITER ;



