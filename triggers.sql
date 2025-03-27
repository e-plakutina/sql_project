-- Обновление статуса контракта на "Выполнен"
CREATE TRIGGER after_battle_complete
AFTER INSERT ON battles
FOR EACH ROW
BEGIN
    UPDATE contracts
    SET status = 'Выполнен'
    WHERE monster_id = NEW.monster_id AND witcher_id = NEW.witcher_id;
END;


-- Награда за выполнение контракта
CREATE TRIGGER after_contract_complete
AFTER UPDATE ON contracts
FOR EACH ROW
BEGIN
    IF NEW.status = 'Выполнен' AND OLD.status != 'Выполнен' THEN
        UPDATE witchers
        SET money = money + NEW.reward
        WHERE id = NEW.witcher_id;
    END IF;
END;


-- Добавление опыта за битву
CREATE TRIGGER after_battle_complete_experience
AFTER INSERT ON battles
FOR EACH ROW
BEGIN
    UPDATE witchers
    SET experience = experience + 50
    WHERE id = NEW.witcher_id;
END;


-- Повышение уровня Ведьмака
CREATE TRIGGER before_witcher_update_level
BEFORE UPDATE ON witchers
FOR EACH ROW
BEGIN
    IF NEW.experience >= 1000 THEN
        SET NEW.level = NEW.level + FLOOR(NEW.experience / 1000);
        SET NEW.experience = NEW.experience % 1000;
    END IF;
END;