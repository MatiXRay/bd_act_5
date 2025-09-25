
CREATE DATABASE steamdb;
USE steamdb; 


-- 1. Usuarios
CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL, -- restricción única
    contrasenia VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    activo BOOLEAN DEFAULT TRUE -- valor por defecto
);

-- 2. Perfiles (relación 1:1 con usuarios)
CREATE TABLE perfiles (
    id_perfil INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT UNIQUE, -- cada usuario tiene solo un perfil
    nickname VARCHAR(50) NOT NULL,
    pais VARCHAR(50),
    descripcion TEXT,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);

-- 3. Juegos
CREATE TABLE juegos (
    id_juego INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    descripcion TEXT,
    fecha_lanzamiento DATE,
    precio DECIMAL(6,2) NOT NULL,
    disponible BOOLEAN DEFAULT TRUE
);

-- 4. Desarrolladores
CREATE TABLE desarrolladores (
    id_desarrollador INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    pais VARCHAR(50)
);

-- 5. Tabla intermedia: Juego - Desarrollador (N:M)
CREATE TABLE juego_desarrollador (
    id_juego INT,
    id_desarrollador INT,
    PRIMARY KEY (id_juego, id_desarrollador),
    FOREIGN KEY (id_juego) REFERENCES juegos(id_juego),
    FOREIGN KEY (id_desarrollador) REFERENCES desarrolladores(id_desarrollador)
);

-- 6. Categorías
CREATE TABLE categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

-- 7. Tabla intermedia: Juego - Categoría (N:M)
CREATE TABLE juego_categoria (
    id_juego INT,
    id_categoria INT,
    PRIMARY KEY (id_juego, id_categoria),
    FOREIGN KEY (id_juego) REFERENCES juegos(id_juego),
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);

CREATE TABLE compras (
    id_compra INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);

-- 9. Detalle de compras (1:N con compras)
CREATE TABLE detalle_compra (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_compra INT,
    id_juego INT,
    FOREIGN KEY (id_compra) REFERENCES compras(id_compra), 	
    FOREIGN KEY (id_juego) REFERENCES juegos(id_juego)
);

-- 10. Reseñas
CREATE TABLE resenas (
    id_resena INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    id_juego INT,
    calificacion INT CHECK (calificacion BETWEEN 1 AND 10),
    comentario TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario)
        REFERENCES usuarios (id_usuario),
    FOREIGN KEY (id_juego)
        REFERENCES juegos (id_juego)
);


INSERT INTO juegos (titulo, descripcion, fecha_lanzamiento, precio, disponible)
VALUES ('Half-Life 3', 'Shooter de Valve', '2025-01-01', 59.99, FALSE);




-- Usuarios
INSERT INTO usuarios (nombre, correo, contrasenia, fecha_nacimiento) VALUES
('Matías', 'matias@gmail.com', '1234', '1998-05-10'),
('Carla', 'carla@hotmail.com', 'abcd', '2001-11-22'),
('Luis', 'luis@yahoo.com', 'pass', '1995-03-15');

-- Perfiles (1 a 1 con usuarios)
INSERT INTO perfiles (id_usuario, nickname, pais, descripcion) VALUES
('Raulo99', 'Argentina', 'Amante de los FPS'),
('Carliitaa', 'Chile', 'Juego de todo un poco'),
('LuchoGamer', 'México', 'Fan de los RPG');

-- Desarrolladores
INSERT INTO desarrolladores (nombre, pais) VALUES
('Valve', 'EEUU'),
('CD Projekt', 'Polonia'),
('Rockstar Games', 'EEUU');

-- Juegos
INSERT INTO juegos (titulo, descripcion, fecha_lanzamiento, precio, disponible) VALUES
('Counter Strike 2', 'Shooter competitivo en línea', '2023-09-27', 15.99, TRUE),
('The Witcher 3', 'RPG de mundo abierto', '2015-05-19', 29.99, TRUE),
('GTA V', 'Acción en mundo abierto', '2013-09-17', 19.99, TRUE);

-- Categorías
INSERT INTO categorias (nombre) VALUES
('Acción'),
('Aventura'),
('RPG'),
('Shooter');

-- Relación Juegos - Categorías (N:M)
INSERT INTO juego_categoria (id_juego, id_categoria) VALUES
(1, 4), -- CS2 es Shooter
(2, 3), -- Witcher 3 es RPG
(2, 2), -- Witcher 3 también Aventura
(3, 1), -- GTA V es Acción
(3, 2); -- GTA V también Aventura

-- Relación Juegos - Desarrolladores (N:M)
INSERT INTO juego_desarrollador (id_juego, id_desarrollador) VALUES
(1, 1), -- CS2 -> Valve
(2, 2), -- Witcher 3 -> CD Projekt
(3, 3); -- GTA V -> Rockstar

-- Compras
INSERT INTO compras (id_usuario) VALUES
(1), -- total se actualizará con detalle
(2);

-- Detalles de compras
INSERT INTO detalle_compra (id_compra, id_juego) VALUES
(1, 1), -- Matías compra CS2
(1, 2), -- Matías compra Witcher 3
(2, 3); -- Carla compra GTA V

-- Reseñas
INSERT INTO resenas (id_usuario, id_juego, calificacion, comentario) VALUES
(1, 1, 9, 'Muy buen juego competitivo'),
(2, 3, 10, 'El mejor mundo abierto'),
(3, 2, 8, 'Gran historia y personajes');

use steamdb;
SELECT 
    r.id_resena,
    u.nombre AS usuario,
    j.titulo AS juego,
    r.calificacion,
    r.comentario
FROM resenas r
INNER JOIN usuarios u ON r.id_usuario = u.id_usuario
INNER JOIN juegos j ON r.id_juego = j.id_juego;



DELIMITER $$

CREATE PROCEDURE InsertarUsuario(
    IN p_nombre VARCHAR(100),
    IN p_correo VARCHAR(100),
    IN p_contrasenia VARCHAR(100),
    IN p_fecha_nacimiento DATE,
    IN p_activo BOOLEAN
)
BEGIN
    INSERT INTO usuarios (nombre, correo, contrasenia, fecha_nacimiento, activo)
    VALUES (p_nombre, p_correo, p_contrasenia, p_fecha_nacimiento, p_activo);
END$$

DELIMITER ;


CALL InsertarUsuario('Raul', 'raul@steam.com', 'clave123', '2000-12-12', TRUE);
select * from usuarios





DELIMITER $$
CREATE PROCEDURE ConsultarResenasUsuariosActivos(
    IN calificacion_minim INT
)
BEGIN
    SELECT 
        u.nombre AS usuario,
        j.titulo AS juego,
        r.calificacion,
        r.comentario,
        r.fecha
    FROM resenas r
    INNER JOIN usuarios u ON r.id_usuario = u.id_usuario
    INNER JOIN juegos j ON r.id_juego = j.id_juego
    WHERE u.activo = TRUE
      AND r.calificacion >= calificacion_minim;
END$$
DELIMITER ;

CALL ConsultarResenasUsuariosActivos(7);

use steamdb;
select * from juegos

DELIMITER $$

CREATE PROCEDURE Juegos_Mayores_20()
BEGIN
    SELECT id_juego, titulo, precio
    FROM juegos
    WHERE precio > 20;
END$$

DELIMITER ;
CALL Juegos_Mayores_20();


DELIMITER $$

CREATE PROCEDURE Juegos_MenoresIgual_20()
BEGIN
    SELECT id_juego, titulo, precio
    FROM juegos
    WHERE precio <= 20;
END$$

DELIMITER ;
CALL Juegos_MenoresIgual_20();


