-- EduTech Academy - MySQL
-- Constraints, Vistas, Usuarios y Triggers

USE edutech_academy;

-- Constraints
ALTER TABLE estudiantes
ADD CONSTRAINT uq_estudiantes_correo
UNIQUE (correo);

ALTER TABLE cursos
ADD CONSTRAINT chk_cursos_nivel
CHECK (nivel IN ('Basico', 'Intermedio', 'Avanzado'));

-- Vistas
CREATE VIEW vista_matriculas AS
SELECT
    CONCAT(e.nombre, ' ', e.apellido) AS nombre_estudiante,
    c.nombre AS nombre_curso,
    m.fecha_matricula,
    c.nivel
FROM matriculas m
INNER JOIN estudiantes e ON m.id_estudiante = e.id_estudiante
INNER JOIN cursos c ON m.id_curso = c.id_curso;

CREATE VIEW vista_cursos_instructores AS
SELECT
    c.nombre AS nombre_curso,
    i.nombre AS nombre_instructor,
    i.especialidad
FROM cursos c
INNER JOIN instructores i ON c.id_instructor = i.id_instructor;

-- Usuarios y permisos
CREATE USER 'admin_edutech'@'localhost' IDENTIFIED BY 'Admin_Edu2026!';
GRANT ALL PRIVILEGES ON edutech_academy.* TO 'admin_edutech'@'localhost';

CREATE USER 'consulta_edutech'@'localhost' IDENTIFIED BY 'Consulta_Edu2026!';
GRANT SELECT ON edutech_academy.vista_matriculas TO 'consulta_edutech'@'localhost';
GRANT SELECT ON edutech_academy.vista_cursos_instructores TO 'consulta_edutech'@'localhost';

-- Trigger: elimina matriculas antes de borrar un curso
DELIMITER //
CREATE TRIGGER trg_eliminar_matriculas
BEFORE DELETE ON cursos
FOR EACH ROW
BEGIN
    DELETE FROM matriculas WHERE id_curso = OLD.id_curso;
END //
DELIMITER ;

-- Trigger: descuenta un cupo al matricular
DELIMITER //
CREATE TRIGGER trg_descontar_cupo
AFTER INSERT ON matriculas
FOR EACH ROW
BEGIN
    UPDATE cursos
    SET cupos_disponibles = cupos_disponibles - 1
    WHERE id_curso = NEW.id_curso;
END //
DELIMITER ;

-- Trigger: valida que haya cupos antes de matricular
DELIMITER //
CREATE TRIGGER trg_validar_cupos
BEFORE INSERT ON matriculas
FOR EACH ROW
BEGIN
    DECLARE cupos INT;
    SELECT cupos_disponibles INTO cupos FROM cursos WHERE id_curso = NEW.id_curso;
    IF cupos IS NULL OR cupos <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El curso no tiene cupos disponibles';
    END IF;
END //
DELIMITER ;

-- Verificaciones
SELECT * FROM vista_matriculas;
SELECT * FROM vista_cursos_instructores;
SHOW TRIGGERS FROM edutech_academy;
SHOW GRANTS FOR 'admin_edutech'@'localhost';
SHOW GRANTS FOR 'consulta_edutech'@'localhost';
SHOW CREATE TABLE estudiantes;
SHOW CREATE TABLE cursos;
