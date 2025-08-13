/* TABLA: choferes_datos
 Se carga datos personales y laborales de cada chofer
*/
CREATE TABLE IF NOT EXISTS choferes_datos(
id_chofer INT PRIMARY KEY AUTO_INCREMENT,
apellido VARCHAR (20),
nombre VARCHAR (30),
fecha_nacimiento DATE NOT NULL,
cuil VARCHAR (11) UNIQUE NOT NULL
CHECK (cuil REGEXP '^[0-9] {2} - [0-9] {8} - [0-9] {1} $'),
dni VARCHAR (10) UNIQUE NOT NULL,
fecha_alta DATE NOT NULL,
tel_corporativo VARCHAR (30) NULL,
tel_personal VARCHAR (30) UNIQUE NOT NULL,
mail VARCHAR (50) UNIQUE NOT NULL,
tel_urgencia VARCHAR (60) NOT NULL,
direccion VARCHAR (50) NOT NULL,
ciudad VARCHAR (20) NOT NULL DEFAULT 'Neuquen',
nacionalidad VARCHAR (20) NOT NULL DEFAULT 'Argentino'
);

/* TABLA: flota_datos
Se carga la nformación técnica de las unidades de flota
  */
CREATE TABLE IF NOT EXISTS flota_datos(
id_flota INT PRIMARY KEY AUTO_INCREMENT,
dominio VARCHAR (10) UNIQUE NOT NULL,
num_motor VARCHAR (50)UNIQUE NOT NULL,
num_chasis VARCHAR (50)UNIQUE NOT NULL,
año YEAR NOT NULL,
marca VARCHAR (20) NOT NULL,
modelo VARCHAR (20) NOT NULL,
fecha_patentamiento DATE NOT NULL
);

/* TABLA: vto_choferes
 Va a pertir ver lo vencimientos de licencias y los aptos de los choferes
*/
CREATE TABLE IF NOT EXISTS Vto_choferes(
id INT PRIMARY KEY AUTO_INCREMENT,
chofer_id INT NOT NULL,
categoria VARCHAR (5) NOT NULL,
lic_nacional DATE NOT NULL,
manejo_defensivo DATE NOT NULL,
psicofisico DATE NOT NULL,
apto_medico DATE NOT NULL,
FOREIGN KEY (chofer_id) REFERENCES choferes_datos(id_chofer)
);

/* TABLA: vto_unidades
 Va a permitir ver los vencimientos y habilitaciones de las unidades
*/
CREATE TABLE IF NOT EXISTS Vto_unidades(
id INT PRIMARY KEY AUTO_INCREMENT,
flota_id INT UNIQUE NOT NULL,
homologacion DATE NOT NULL,
rto_nac_prov DATE NOT NULL,
habilitacion_transporte DATE NOT NULL,
tacografo DATE NOT NULL,
check_list DATE NOT NULL,
FOREIGN KEY (flota_id) REFERENCES flota_datos (id_flota) 
);

/* TABLA: empresas
  Se cargan las Empresas - clientes para asociar usuarios y servicios
*/
CREATE TABLE IF NOT EXISTS empresas(
id_empresa INT PRIMARY KEY AUTO_INCREMENT,
nombre_empresa VARCHAR (50) NOT NULL,
cuit_empresa VARCHAR (20)  UNIQUE NOT NULL
) ENGINE=InnoDB;

-- voy a modificar a las tablas para resguardar datos
ALTER TABLE choferes_datos ENGINE=InnoDB;
ALTER TABLE flota_datos ENGINE=InnoDB;
ALTER TABLE vto_choferes ENGINE=InnoDB;
ALTER TABLE vto_unidades ENGINE=InnoDB;

/* TABLA: usuarios
  Se registra a cada usuarios, quienes van a estar vinculados a la empresa que pertenecen
*/
CREATE TABLE IF NOT EXISTS usuarios(
id_usuario INT PRIMARY KEY AUTO_INCREMENT,
id_empresa INT NOT NULL,
nombre VARCHAR (50) NOT NULL,
apellido VARCHAR (50) NOT NULL,
dni VARCHAR (20),
tel_usuario VARCHAR (30) NOT NULL,
FOREIGN KEY (id_empresa) REFERENCES empresas(id_empresa)
) ENGINE=InnoDB;


-- IDEA : la tabla de vencimientos unidades/choferes va a estar ligada al control documental, tambien falta crear tabla de contratos (PROYECTO FINAL)

/* TABLA: grilla_servicio
  Registra los servicios realizados y por realizar, permite el calculo de distancia -tiempo de cada recorrido
*/
CREATE TABLE IF NOT EXISTS grilla_servicio (
id_servicio INT PRIMARY KEY AUTO_INCREMENT,
id_usuario INT NOT NULL,
id_chofer INT NOT NULL,
id_unidad INT NOT NULL,
fecha_servicio DATE NOT NULL,
horario_salida  TIME NOT NULL,
direccion_salida VARCHAR (200) NOT NULL,
horario_llegada TIME NOT NULL,
direccion_llegada VARCHAR (200) NOT NULL,
km_recorrido DECIMAL (8,2) NOT NULL,
tiempo_recorrido TIME NOT NULL,
FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
FOREIGN KEY (id_chofer) REFERENCES choferes_datos(id_chofer),
FOREIGN KEY (id_unidad) REFERENCES flota_datos(id_flota)
) ENGINE=InnoDB;

DESCRIBE grilla_servicio;


CREATE VIEW vista_servicios_resumen AS
SELECT 
gs.fecha_servicio,
CONCAT(u.nombre, ' ', u.apellido) AS usuario,
gs.horario_salida,
gs.direccion_salida,
CONCAT(c.apellido, ' ', c.nombre) AS chofer,
CONCAT(f.marca, ' ', f.modelo, ' (', f.dominio, ')') AS unidad
FROM grilla_servicio gs
JOIN usuarios u ON gs.id_usuario = u.id_usuario
JOIN choferes_datos c ON gs.id_chofer = c.id_chofer
JOIN flota_datos f ON gs.id_unidad = f.id_flota
;
