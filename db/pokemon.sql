CREATE TABLE pokemons (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  level INTEGER NOT NULL,
  type VARCHAR(255) NOT NULL,
  trainer_id INTEGER,

  FOREIGN KEY(trainer_id) REFERENCES trainer(id)
);

CREATE TABLE trainers (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

CREATE TABLE moves (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  type VARCHAR(255) NOT NULL
);

CREATE TABLE pokemon_move_possessions (
  id INTEGER PRIMARY KEY,
  pokemon_id INTEGER NOT NULL,
  move_id INTEGER NOT NULL,

  FOREIGN KEY(pokemon_id) REFERENCES pokemon(id),
  FOREIGN KEY(move_id) REFERENCES move(id)
);

INSERT INTO
  trainers (id, fname, lname)
VALUES
  (1, "Ash", "Ketchum"),
  (2, "Gary", "Oak"),
  (3, "Misty", "Cerulean"),
  (4, "Brock", "Pewter");

INSERT INTO
  pokemons (id, name, level, type, trainer_id)
VALUES
  (1, "Pikachu", 10, "Electric", 1),
  (2, "Staryu", 15, "Water", 3),
  (3, "Eevee", 10, "Normal", 2),
  (4, "Geodude", 13, "Rock", 4),
  (5, "Bulbasaur", 5, "Grass", 1),
  (6, "Squirtle", 5, "Water", 1),
  (7, "Charmander", 5, "Fire", 1);

INSERT INTO
  moves (id, name, type)
VALUES
  (1, "Tackle", "Normal"),
  (2, "Scratch", "Normal"),
  (3, "Water Gun", "Water"),
  (4, "Ember", "Fire"),
  (5, "Thundershock", "Electric"),
  (6, "Harden", "Normal"),
  (7, "Tail Whip", "Normal"),
  (8, "Vine Whip", "Grass");

INSERT INTO
  pokemon_move_possessions (id, pokemon_id, move_id)
VALUES
  (1, 1, 5),
  (2, 2, 3),
  (3, 3, 1),
  (4, 3, 2),
  (5, 4, 1),
  (6, 4, 6),
  (7, 5, 8),
  (8, 5, 1),
  (9, 6, 1),
  (10, 6, 3),
  (11, 7, 2),
  (12, 7, 4);
