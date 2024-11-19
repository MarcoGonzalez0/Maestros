CREATE DATABASE maestros;
USE maestros;


-- Crear la tabla Region
CREATE TABLE Region (
    idRegion INT NOT NULL AUTO_INCREMENT,
    nombreRegion VARCHAR(64),
    PRIMARY KEY (idRegion)
);

-- Crear la tabla Comuna
-- Modificar la tabla Comuna
CREATE TABLE Comuna (
    idComuna INT NOT NULL AUTO_INCREMENT,
    nombreComuna VARCHAR(100) NOT NULL,
    Region_idRegion INT NOT NULL,
    Borrar INT NOT NULL,
    PRIMARY KEY (idComuna),
    CONSTRAINT Comuna_Region_FK FOREIGN KEY (Region_idRegion)
        REFERENCES Region(idRegion)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

-- Modificar la tabla Especialidad
CREATE TABLE Especialidad (
    idEspecialidad INT NOT NULL AUTO_INCREMENT,
    nombreEspecialidad VARCHAR(60),
    desc_especialidad VARCHAR(255),
    PRIMARY KEY (idEspecialidad)
);

-- Modificar la tabla Maestro
CREATE TABLE Maestro (
    idMaestro INT NOT NULL AUTO_INCREMENT,
    nombreMaestro VARCHAR(60) NULL,
    titulo_especialidad TEXT,
    descripcionMaestro TEXT,
    Comuna_idComuna INT NULL,
    Especialidad_idEspecialidad INT NULL,
    seccion CHAR(1),
    email VARCHAR(255) NULL,
    direccion VARCHAR(255) NULL,
    fecha_reg DATETIME,
    PRIMARY KEY (idMaestro),
    CONSTRAINT Maestro_Comuna_FK FOREIGN KEY (Comuna_idComuna)
        REFERENCES Comuna(idComuna)
        ON DELETE CASCADE
        ON UPDATE CASCADE,  -- Cambié NO ACTION por CASCADE en ON DELETE
    CONSTRAINT Maestro_Especialidad_FK FOREIGN KEY (Especialidad_idEspecialidad)
        REFERENCES Especialidad(idEspecialidad)
        ON DELETE CASCADE
        ON UPDATE CASCADE  -- Cambié NO ACTION por CASCADE en ON DELETE
);

-- Modificar la tabla Telefonos_Maestros
CREATE TABLE Telefonos_Maestros (
    idTelefono INT NOT NULL AUTO_INCREMENT,
    numero VARCHAR(15),
    Maestro_idMaestro INT NOT NULL,
    PRIMARY KEY (idTelefono),
    CONSTRAINT Telefonos_Maestros_Maestro_FK FOREIGN KEY (Maestro_idMaestro)
        REFERENCES Maestro(idMaestro)
        ON DELETE CASCADE  -- Cambié NO ACTION por CASCADE en ON DELETE
        ON UPDATE CASCADE
);


-- Crear la tabla Tipo_Usuario
CREATE TABLE Tipo_Usuario (
    idTipo INT NOT NULL,
    nombre VARCHAR(20),
    PRIMARY KEY (idTipo)
);

-- Crear la tabla Usuario con la clave foránea hacia Tipo_Usuario
CREATE TABLE Usuario (
    idUsuario INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(60) NOT NULL,
    appat VARCHAR(60) NOT NULL,
    apmat VARCHAR(60),
    direccion VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    Comuna_idComuna INT NULL,
    telefonoUsuario VARCHAR(15),
	fecha_reg DATETIME,
    Tipo_Usuario_idTipo INT NOT NULL,
    PRIMARY KEY (idUsuario),
    CONSTRAINT Usuario_Comuna_FK FOREIGN KEY (Comuna_idComuna)
        REFERENCES Comuna(idComuna)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT Usuario_Tipo_FK FOREIGN KEY (Tipo_Usuario_idTipo)
        REFERENCES Tipo_Usuario(idTipo)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);



-- Crear la tabla Acceso
CREATE TABLE Acceso (
    idAcceso INT NOT NULL AUTO_INCREMENT,
    username VARCHAR(100) NOT NULL,
    llave VARCHAR(100) NOT NULL,
    fechaCaducidadLLave DATETIME NOT NULL,
    diasCaducaLLave INT NOT NULL,
    estadoInicial TINYINT(1) NOT NULL,
    estadoAcceso TINYINT(1) NOT NULL,
    Usuario_idUsuario INT NOT NULL,
    PRIMARY KEY (idAcceso),
    CONSTRAINT Acceso_Usuario_FK FOREIGN KEY (Usuario_idUsuario)
        REFERENCES Usuario(idUsuario)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- evento para evaluar la fecha de caducidad de los accesos y denegar acceso
SET GLOBAL event_scheduler = ON;
CREATE EVENT IF NOT EXISTS actualizar_estado_acceso
ON SCHEDULE EVERY 1 DAY -- Se ejecuta cada día
STARTS CURRENT_TIMESTAMP -- Empieza a ejecutarse inmediatamente
DO
  UPDATE Acceso
  SET estadoAcceso = 0
  WHERE fechaCaducidadLLave < NOW() AND estadoAcceso = 1;


-- Crear un índice único para Usuario_idUsuario en la tabla Acceso
CREATE UNIQUE INDEX Acceso__IDX ON Acceso (Usuario_idUsuario);

-- Insertar tipos de usuario
INSERT INTO Tipo_Usuario (idTipo, nombre) VALUES
    (1, 'Normal'),
    (2, 'Administrador');

-- Insertar especialidades
INSERT INTO Especialidad (nombreEspecialidad, desc_especialidad) VALUES
('Gasfitería', 'Instalación y reparación de sistemas de agua y gas.'),
('Electricidad', 'Instalación y mantenimiento de sistemas eléctricos.'),
('Carpintería', 'Fabricación, montaje y reparación de estructuras de madera.'),
('Albañilería', 'Construcción y reparación de muros, pisos y acabados en obras.'),
('Pintura', 'Aplicación de pintura en interiores y exteriores de construcciones.'),
('Soldadura', 'Uniones y reparaciones de estructuras metálicas.'),
('Cerámica y Revestimiento', 'Colocación de cerámicas y revestimientos en pisos y paredes.'),
('Mueblería', 'Fabricación y reparación de muebles de madera.'),
('Climatización', 'Instalación y mantenimiento de sistemas de calefacción, ventilación y aire acondicionado.'),
('Jardinería y Paisajismo', 'Diseño y mantenimiento de áreas verdes y jardines.'),
('Yesería y Estuco', 'Aplicación de acabados de yeso y estuco en paredes y cielos.'),
('Techumbre', 'Instalación y reparación de techos.'),
('Instalación de Ventanas y Vidriería', 'Montaje y reparación de ventanas y estructuras de cristal.'),
('Mantención de Electrodomésticos', 'Reparación de equipos como lavadoras y refrigeradores.'),
('Terminaciones y Acabados', 'Instalación de molduras, papeles murales y detalles de interiores.');

-- insertar regiones
INSERT INTO `Region` (`idRegion`,`nombreRegion`)
VALUES
	(1,'Arica y Parinacota'),
	(2,'Tarapacá'),
	(3,'Antofagasta'),
	(4,'Atacama'),
	(5,'Coquimbo'),
	(6,'Valparaiso'),
	(7,'Metropolitana de Santiago'),
	(8,'Libertador General Bernardo OHiggins'),
	(9,'Maule'),
	(10,'Ñuble'),
	(11,'Biobío'),
	(12,'La Araucanía'),
	(13,'Los Ríos'),
	(14,'Los Lagos'),
	(15,'Aysén del General Carlos Ibáñez del Campo'),
	(16,'Magallanes y de la Antártica Chilena');



INSERT INTO `Comuna` (`nombreComuna`,`Region_idRegion`, `Borrar`)
VALUES
	("Arica","1","1"),
	("Camarones","1","1"),
	("Putre","1","1"),
	("General Lagos","1","1"),
	("Iquique","2","1"),
	("Alto Hospicio","2","1"),
	("Pozo Almonte","2","1"),
	("Camiña","2","1"),
	("Colchane","2","1"),
	("Huara","2","1"),
	("Pica","2","1"),
	("Antofagasta","3","1"),
	("Mejillones","3","1"),
	("Sierra Gorda","3","1"),
	("Taltal","3","1"),
	("Calama","3","1"),
	("Ollagüe","3","1"),
	("San Pedro de Atacama","3","1"),
	("Tocopilla","3","1"),
	("María Elena","3","1"),
	("Copiapó","4","1"),
	("Caldera","4","1"),
	("Tierra Amarilla","4","1"),
	("Chañaral","4","1"),
	("Diego de Almagro","4","1"),
	("Vallenar","4","1"),
	("Alto del Carmen","4","1"),
	("Freirina","4","1"),
	("Huasco","4","1"),
	("La Serena","5","1"),
	("Coquimbo","5","1"),
	("Andacollo","5","1"),
	("La Higuera","5","1"),
	("Paihuano","5","1"),
	("Vicuña","5","1"),
	("Illapel","5","1"),
	("Canela","5","1"),
	("Los Vilos","5","1"),
	("Salamanca","5","1"),
	("Ovalle","5","1"),
	("Combarbalá","5","1"),
	("Monte Patria","5","1"),
	("Punitaqui","5","1"),
	("Río Hurtado","5","1"),
	("Valparaíso","6","1"),
	("Casablanca","6","1"),
	("Concón","6","1"),
	("Juan Fernández","6","1"),
	("Puchuncaví","6","1"),
	("Quintero","6","1"),
	("Viña del Mar","6","1"),
	("Isla de Pascua","6","1"),
	("Los Andes","6","1"),
	("Calle Larga","6","1"),
	("Rinconada","6","1"),
	("San Esteban","6","1"),
	("La Ligua","6","1"),
	("Cabildo","6","1"),
	("Papudo","6","1"),
	("Petorca","6","1"),
	("Zapallar","6","1"),
	("Quillota","6","1"),
	("La Calera","6","1"),
	("Hijuelas","6","1"),
	("La Cruz","6","1"),
	("Nogales","6","1"),
	("San Antonio","6","1"),
	("Algarrobo","6","1"),
	("Cartagena","6","1"),
	("El Quisco","6","1"),
	("El Tabo","6","1"),
	("Santo Domingo","6","1"),
	("San Felipe","6","1"),
	("Catemu","6","1"),
	("Llay-Llay","6","1"),
	("Panquehue","6","1"),
	("Putaendo","6","1"),
	("Santa María","6","1"),
	("Quilpué","6","1"),
	("Limache","6","1"),
	("Olmué","6","1"),
	("Villa Alemana","6","1"),
	("Rancagua","8","1"),
	("Codegua","8","1"),
	("Coinco","8","1"),
	("Coltauco","8","1"),
	("Doñihue","8","1"),
	("Graneros","8","1"),
	("Las Cabras","8","1"),
	("Machalí","8","1"),
	("Malloa","8","1"),
	("Mostazal","8","1"),
	("Olivar","8","1"),
	("Peumo","8","1"),
	("Pichidegua","8","1"),
	("Quinta de Tilcoco","8","1"),
	("Rengo","8","1"),
	("Requínoa","8","1"),
	("San Vicente","8","1"),
	("Pichilemu","8","1"),
	("La Estrella","8","1"),
	("Litueche","8","1"),
	("Marchihue","8","1"),
	("Navidad","8","1"),
	("Paredones","8","1"),
	("San Fernando","8","1"),
	("Chépica","8","1"),
	("Chimbarongo","8","1"),
	("Lolol","8","1"),
	("Nancagua","8","1"),
	("Palmilla","8","1"),
	("Peralillo","8","1"),
	("Placilla","8","1"),
	("Pumanque","8","1"),
	("Santa Cruz","8","1"),
	("Talca","9","1"),
	("Constitución","9","1"),
	("Curepto","9","1"),
	("Empedrado","9","1"),
	("Maule","9","1"),
	("Pelarco","9","1"),
	("Pencahue","9","1"),
	("Río Claro","9","1"),
	("San Clemente","9","1"),
	("San Rafael","9","1"),
	("Cauquenes","9","1"),
	("Chanco","9","1"),
	("Pelluhue","9","1"),
	("Curicó","9","1"),
	("Hualañé","9","1"),
	("Licantén","9","1"),
	("Molina","9","1"),
	("Rauco","9","1"),
	("Romeral","9","1"),
	("Sagrada Familia","9","1"),
	("Teno","9","1"),
	("Vichuquén","9","1"),
	("Linares","9","1"),
	("Colbún","9","1"),
	("Longaví","9","1"),
	("Parral","9","1"),
	("Retiro","9","1"),
	("San Javier","9","1"),
	("Villa Alegre","9","1"),
	("Yerbas Buenas","9","1"),
	("Chillán","10","1"),
	("Bulnes","10","1"),
	("Chillán Viejo","10","1"),
	("El Carmen","10","1"),
	("Pemuco","10","1"),
	("Pinto","10","1"),
	("Quillón","10","1"),
	("San Ignacio","10","1"),
	("Yungay","10","1"),
	("Quirihue","10","1"),
	("Cobquecura","10","1"),
	("Coelemu","10","1"),
	("Ninhue","10","1"),
	("Portezuelo","10","1"),
	("Ránquil","10","1"),
	("Treguaco","10","1"),
	("San Carlos","10","1"),
	("Coihueco","10","1"),
	("Ñiquén","10","1"),
	("San Fabián","10","1"),
	("San Nicolás","10","1"),
	("Concepción","11","1"),
	("Coronel","11","1"),
	("Chiguayante","11","1"),
	("Florida","11","1"),
	("Hualqui","11","1"),
	("Lota","11","1"),
	("Penco","11","1"),
	("San Pedro de La Paz","11","1"),
	("Santa Juana","11","1"),
	("Talcahuano","11","1"),
	("Tomé","11","1"),
	("Hualpén","11","1"),
	("Lebu","11","1"),
	("Arauco","11","1"),
	("Cañete","11","1"),
	("Contulmo","11","1"),
	("Curanilahue","11","1"),
	("Los Álamos","11","1"),
	("Tirúa","11","1"),
	("Los Ángeles","11","1"),
	("Antuco","11","1"),
	("Cabrero","11","1"),
	("Laja","11","1"),
	("Mulchén","11","1"),
	("Nacimiento","11","1"),
	("Negrete","11","1"),
	("Quilaco","11","1"),
	("Quilleco","11","1"),
	("San Rosendo","11","1"),
	("Santa Bárbara","11","1"),
	("Tucapel","11","1"),
	("Yumbel","11","1"),
	("Alto Biobío","11","1"),
	("Temuco","12","1"),
	("Carahue","12","1"),
	("Cunco","12","1"),
	("Curarrehue","12","1"),
	("Freire","12","1"),
	("Galvarino","12","1"),
	("Gorbea","12","1"),
	("Lautaro","12","1"),
	("Loncoche","12","1"),
	("Melipeuco","12","1"),
	("Nueva Imperial","12","1"),
	("Padre Las Casas","12","1"),
	("Perquenco","12","1"),
	("Pitrufquén","12","1"),
	("Pucón","12","1"),
	("Saavedra","12","1"),
	("Teodoro Schmidt","12","1"),
	("Toltén","12","1"),
	("Vilcún","12","1"),
	("Villarrica","12","1"),
	("Cholchol","12","1"),
	("Angol","12","1"),
	("Collipulli","12","1"),
	("Curacautín","12","1"),
	("Ercilla","12","1"),
	("Lonquimay","12","1"),
	("Los Sauces","12","1"),
	("Lumaco","12","1"),
	("Purén","12","1"),
	("Renaico","12","1"),
	("Traiguén","12","1"),
	("Victoria","12","1"),
	("Valdivia","13","1"),
	("Corral","13","1"),
	("Lanco","13","1"),
	("Los Lagos","13","1"),
	("Máfil","13","1"),
	("Mariquina","13","1"),
	("Paillaco","13","1"),
	("Panguipulli","13","1"),
	("La Unión","13","1"),
	("Futrono","13","1"),
	("Lago Ranco","13","1"),
	("Río Bueno","13","1"),
	("Puerto Montt","14","1"),
	("Calbuco","14","1"),
	("Cochamó","14","1"),
	("Fresia","14","1"),
	("Frutillar","14","1"),
	("Los Muermos","14","1"),
	("Llanquihue","14","1"),
	("Maullín","14","1"),
	("Puerto Varas","14","1"),
	("Castro","14","1"),
	("Ancud","14","1"),
	("Chonchi","14","1"),
	("Curaco de Vélez","14","1"),
	("Dalcahue","14","1"),
	("Puqueldón","14","1"),
	("Queilén","14","1"),
	("Quellón","14","1"),
	("Quemchi","14","1"),
	("Quinchao","14","1"),
	("Osorno","14","1"),
	("Puerto Octay","14","1"),
	("Purranque","14","1"),
	("Puyehue","14","1"),
	("Río Negro","14","1"),
	("San Juan de la Costa","14","1"),
	("San Pablo","14","1"),
	("Chaitén","14","1"),
	("Futaleufú","14","1"),
	("Hualaihué","14","1"),
	("Palena","14","1"),
	("Coyhaique","15","1"),
	("Lago Verde","15","1"),
	("Aysén","15","1"),
	("Cisnes","15","1"),
	("Guaitecas","15","1"),
	("Cochrane","15","1"),
	("O'Higgins","15","1"),
	("Tortel","15","1"),
	("Chile Chico","15","1"),
	("Río Ibáñez","15","1"),
	("Punta Arenas","16","1"),
	("Laguna Blanca","16","1"),
	("Río Verde","16","1"),
	("San Gregorio","16","1"),
	("Cabo de Hornos","16","1"),
	("Antártica","16","1"),
	("Porvenir","16","1"),
	("Primavera","16","1"),
	("Timaukel","16","1"),
	("Natales","16","1"),
	("Torres del Paine","16","1"),
	("Santiago","7","1"),
	("Cerrillos","7","1"),
	("Cerro Navia","7","1"),
	("Conchalí","7","1"),
	("El Bosque","7","1"),
	("Estación Central","7","1"),
	("Huechuraba","7","1"),
	("Independencia","7","1"),
	("La Cisterna","7","1"),
	("La Florida","7","1"),
	("La Granja","7","1"),
	("La Pintana","7","1"),
	("La Reina","7","1"),
	("Las Condes","7","1"),
	("Lo Barnechea","7","1"),
	("Lo Espejo","7","1"),
	("Lo Prado","7","1"),
	("Macul","7","1"),
	("Maipú","7","1"),
	("Ñuñoa","7","1"),
	("Pedro Aguirre Cerda","7","1"),
	("Peñalolén","7","1"),
	("Providencia","7","1"),
	("Pudahuel","7","1"),
	("Quilicura","7","1"),
	("Quinta Normal","7","1"),
	("Recoleta","7","1"),
	("Renca","7","1"),
	("San Joaquín","7","1"),
	("San Miguel","7","1"),
	("San Ramón","7","1"),
	("Vitacura","7","1"),
	("Puente Alto","7","1"),
	("Pirque","7","1"),
	("San José de Maipo","7","1"),
	("Colina","7","1"),
	("Lampa","7","1"),
	("Til Til","7","1"),
	("San Bernardo","7","1"),
	("Buin","7","1"),
	("Calera de Tango","7","1"),
	("Paine","7","1"),
	("Melipilla","7","1"),
	("Alhué","7","1"),
	("Curacaví","7","1"),
	("María Pinto","7","1"),
	("San Pedro","7","1"),
	("Talagante","7","1"),
	("El Monte","7","1"),
	("Isla de Maipo","7","1"),
	("Padre Hurtado","7","1"),
	("Peñaflor","7","1");

-- Borrar columna que sobra
ALTER TABLE Comuna DROP COLUMN Borrar;




-- Procedimiento para ingresar datos en Usuario y en Acceso
DELIMITER $$

CREATE PROCEDURE sp_InsertarUsuarioyAcceso(
    IN p_nombre VARCHAR(60),
    IN p_appat VARCHAR(60),
    IN p_apmat VARCHAR(60),
    IN p_direccion VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_Comuna_idComuna INT,
    IN p_telefonoUsuario VARCHAR(15),
    IN p_username VARCHAR(100),
    IN p_llave VARCHAR(100),
    IN p_tipo_usuario INT
)
BEGIN
	DECLARE last_user_id INT;
    -- Inicia la transacción
    START TRANSACTION;

    -- Inserta el nuevo registro en la tabla Usuario
    INSERT INTO Usuario (
        nombre, appat, apmat, direccion, email, Comuna_idComuna, telefonoUsuario, fecha_reg, Tipo_Usuario_idTipo
    ) 
    VALUES (
        p_nombre, p_appat, p_apmat, p_direccion, p_email, p_Comuna_idComuna, p_telefonoUsuario, CURDATE(), p_tipo_usuario
    );

    -- Obtén el ID generado automáticamente del último registro insertado
    SET last_user_id = LAST_INSERT_ID(); -- Este ID es del usuario recién insertado

    -- Inserta los datos de username y llave en la tabla Acceso
    -- Valores predeterminados para los campos de Acceso
    INSERT INTO Acceso (
        username, llave, fechaCaducidadLLave, diasCaducaLLave, estadoInicial, estadoAcceso, Usuario_idUsuario
    )
    VALUES (
        p_username, p_llave, DATE_ADD(CURDATE(), INTERVAL 1 YEAR), 365, 1, 1, last_user_id
    );

    -- Confirma la transacción
    COMMIT;
END $$

DELIMITER ;



-- Procedmiento para guardar maestro y su telefono
DELIMITER $$

CREATE PROCEDURE sp_InsertarMaestroYTelefono(
    IN p_nombreMaestro VARCHAR(60),
	IN titulo_especialidad TEXT,
    IN p_descripcionMaestro TEXT,
    IN p_Comuna_idComuna INT,
    IN p_Especialidad_idEspecialidad INT,
    IN p_seccion CHAR(1),
    IN p_email VARCHAR(255),
    IN p_direccion VARCHAR(255),
	-- tabla telefonos
    IN p_telefono VARCHAR(15)
)
BEGIN
    -- Declarar una variable para almacenar el ID del Maestro insertado
    DECLARE v_idMaestro INT;

    -- Iniciar transacción
    START TRANSACTION;

    -- Insertar el nuevo Maestro
    INSERT INTO Maestro (
        nombreMaestro,
		titulo_especialidad,
        descripcionMaestro,
        Comuna_idComuna,
        Especialidad_idEspecialidad,
        seccion,
        email,
        direccion,
        fecha_reg
    ) 
    VALUES (
        p_nombreMaestro,
		titulo_especialidad,
        p_descripcionMaestro,
        p_Comuna_idComuna,
        p_Especialidad_idEspecialidad,
        p_seccion,
        p_email,
        p_direccion,
        NOW()  -- Se usa NOW() para la fecha actual
    );

    -- Obtener el ID del Maestro insertado
    SET v_idMaestro = LAST_INSERT_ID();

    -- Insertar el teléfono del maestro en la tabla Telefonos_Maestros
    INSERT INTO Telefonos_Maestros (
        numero,
        Maestro_idMaestro
    )
    VALUES (
        p_telefono,
        v_idMaestro  -- Usar el ID del Maestro insertado
    );

    -- Confirmar la transacción
    COMMIT;

END $$

DELIMITER ;




DELIMITER $$

CREATE PROCEDURE sp_ActualizarMaestro (
    IN p_idMaestro INT,
    IN p_nombreMaestro VARCHAR(60),
    IN p_tituloEspecialidad TEXT,
    IN p_descripcionMaestro TEXT,
    IN p_idComuna INT,  -- Puede ser NULL
    IN p_email VARCHAR(255),
    IN p_telefono VARCHAR(15),
    IN p_idEspecialidad INT  -- Puede ser NULL
)
BEGIN
    -- Actualizar el maestro
    UPDATE Maestro
    SET 
        nombreMaestro = p_nombreMaestro,
        titulo_especialidad = p_tituloEspecialidad,
        descripcionMaestro = p_descripcionMaestro,
        Comuna_idComuna = p_idComuna,
        Especialidad_idEspecialidad = p_idEspecialidad,
        email = p_email
    WHERE idMaestro = p_idMaestro;
    
    -- Actualizar telefono del maestro
    UPDATE Telefonos_Maestros
    SET 
        numero = p_telefono
    WHERE Maestro_idMaestro = p_idMaestro;

END$$

DELIMITER ;


-- crear admin
CALL sp_InsertarUsuarioyAcceso('Pedro', 'Rojas', 'Soto', 'Calle #2', 'Pedro@admin.cl', 222,'78945623', 'admin', 'admin',2);

-- crear usuario normal con acceso
CALL sp_InsertarUsuarioyAcceso('Juan', 'Soto', 'Rojas', 'Calle #5', 'juan_sr@maestro.cl', 200,'78945623', 'user', 'user',1);




