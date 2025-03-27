CREATE TABLE witchers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    school VARCHAR(255) NOT NULL,
    level INT DEFAULT 0 NOT NULL,
    money INT DEFAULT 0 NOT NULL,
    experience INT DEFAULT 0 NOT NULL,
    created_at DATETIME NOT NULL COMMENT 'Date when a witcher entered the Guild'
)
COLLATE = utf8mb4_general_ci;


CREATE TABLE monsters (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(255) NOT NULL,
    danger_level INT NOT NULL,
    location VARCHAR(255) NOT NULL COMMENT 'Approximate location where a monster lives',
    weakness JSON NULL
);


CREATE TABLE equipment (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(255) NOT NULL,
    damage INT DEFAULT 0 NOT NULL,
    enchantment TINYINT(1) NOT NULL,
    witcher_id INT NOT NULL,
    CONSTRAINT equipment_witchers_id_fk FOREIGN KEY (witcher_id) REFERENCES witchers (id)
);


CREATE TABLE cities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    region VARCHAR(255) NOT NULL,
    population INT NOT NULL
)
COMMENT 'Cities where a witcher can find a contract';


CREATE TABLE contracts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    monster_id INT NOT NULL,
    city_id INT NOT NULL,
    reward INT DEFAULT 0 NOT NULL,
    status VARCHAR(255) NOT NULL,
    witcher_id INT NOT NULL COMMENT 'Witcher who has taken the contract',
    created_at DATETIME NOT NULL,
    CONSTRAINT contracts_monsters_id_fk FOREIGN KEY (monster_id) REFERENCES monsters (id),
    CONSTRAINT contracts_cities_id_fk FOREIGN KEY (city_id) REFERENCES cities (id),
    CONSTRAINT contracts_witchers_id_fk FOREIGN KEY (witcher_id) REFERENCES witchers (id)
);


CREATE TABLE battles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    witcher_id INT NOT NULL,
    monster_id INT NOT NULL,
    outcome VARCHAR(255) NOT NULL,
    date DATETIME NULL,
    CONSTRAINT battles_monsters_id_fk FOREIGN KEY (monster_id) REFERENCES monsters (id),
    CONSTRAINT battles_witchers_id_fk FOREIGN KEY (witcher_id) REFERENCES witchers (id)
);


CREATE TABLE alchemy (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    effect VARCHAR(255) NOT NULL,
    required_ingridients JSON NOT NULL
)
COMMENT 'Potions and oils which a witcher can make';


CREATE TABLE witcher_alchemy (
    id INT AUTO_INCREMENT PRIMARY KEY,
    witcher_id INT NOT NULL,
    alchemy_id INT NOT NULL,
    CONSTRAINT witcher_alchemy_pk_2 UNIQUE (witcher_id, alchemy_id),
    CONSTRAINT witcher_alchemy_alchemy_id_fk FOREIGN KEY (alchemy_id) REFERENCES alchemy (id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT witcher_alchemy_witchers_id_fk FOREIGN KEY (witcher_id) REFERENCES witchers (id)
        ON UPDATE CASCADE ON DELETE CASCADE
);
