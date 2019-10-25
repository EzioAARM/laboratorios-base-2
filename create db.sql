DROP DATABASE IF EXISTS ABCareolinea;
GO
CREATE DATABASE ABCaerolinea 
GO

USE ABCaerolinea
GO

/*
	Supertipo persona para luego dividirlo en Cliente o trabajador
*/
CREATE TABLE Persona (
	Identificacion INT PRIMARY KEY, 
	Nombres VARCHAR(50), 
	Apellidos VARCHAR(50), 
	Nacionalidad VARCHAR(50), 
	Fecha_Nacimiento DATE
)

/*
	Informacion sobre los clientes
*/
CREATE TABLE Cliente (
	id_cliente INT PRIMARY KEY,
	id_persona INT NOT NULL, 
	informacion_Relevante VARCHAR(250),
	CONSTRAINT fk_Cliente_Persona FOREIGN KEY (id_persona) REFERENCES Persona(Identificacion)
	ON DELETE CASCADE
	ON UPDATE CASCADE
)

/*
	Informacion sobre los empleados que tiene la empresa
*/
CREATE TABLE Trabajador (
	codigo_trabajador INT PRIMARY KEY, 
	id_persona INT NOT NULL,
	Salario_A decimal NOT NULL,
	activo BIT,
	fecha_contratacion DATETIME,
	CONSTRAINT fk_Trabajador_Persona FOREIGN KEY (id_persona) REFERENCES Persona(Identificacion)
	ON DELETE CASCADE
	ON UPDATE CASCADE
)

/*
	Guarda informacion sobre el historial de salarios que han tenido los empleados
*/
CREATE TABLE Salarios(
	codigo_trabajador INT NOT NULL,
	salario DECIMAL NOT NULL,
	Fecha_pago DATETIME NOT NULL,
	CONSTRAINT Pk_cTrabajador_Salario PRIMARY KEY (codigo_trabajador, Fecha_pago)
)

/*
	Guarda informacion sobre los aviones que tiene la empresa
*/
CREATE TABLE Avion (
	id_avion INT PRIMARY KEY,
	Cantidad_maxima INT NOT NULL,
	Tipo_Avion VARCHAR(50)
)

/*
	Guarda informacion sobre los paises en los que hay aeropuertos
*/
CREATE TABLE Pais(
	id_pais INT PRIMARY KEY IDENTITY (1,1),
	Nombre VARCHAR(100) NOT NULL
)

/*
	Guarda informacion sobre las ciudades en las que hay aeropuertos
*/
CREATE TABLE Ciudad(
	id_ciudad INT PRIMARY KEY,
	id_pais INT NOT NULL,
	nombre VARCHAR(100),
	CONSTRAINT fk_ciudad_pais FOREIGN KEY (id_pais) REFERENCES Pais(id_pais)
	ON DELETE CASCADE
	ON UPDATE CASCADE
)

/*
	Tiene informacion sobre puntos de partida y destinos (aeropuertos)
*/
CREATE TABLE Aeropuertos (
	id_aeropuerto INT PRIMARY KEY,
	id_ciudad INT NOT NULL,
	nombre VARCHAR(100),
	CONSTRAINT fk_Aeropuerto_Ciudad FOREIGN KEY (id_ciudad) REFERENCES Ciudad(id_ciudad)
	ON DELETE CASCADE
	ON UPDATE CASCADE
)

/*
	Guarda el origen y el destino del vuelo, el resto de informacion se encuentra en la tabla "Escala"
*/
CREATE TABLE Vuelo(
	id_vuelo INT PRIMARY KEY IDENTITY(1, 1),
	origen INT NOT NULL,
	destino INT NOT NULL,
	CONSTRAINT fk_origen_aeropuerto FOREIGN KEY (origen) REFERENCES Aeropuertos(id_aeropuerto)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT fk_destino_aeropuerto FOREIGN KEY (destino) REFERENCES Aeropuertos(id_aeropuerto)
	ON DELETE CASCADE
	ON UPDATE CASCADE
)

/*
	El listado de escalas relacionados con un vuelo especifico
*/
CREATE TABLE Escala(
	id_escala INT PRIMARY KEY IDENTITY(1, 1),
	id_vuelo INT NOT NULL,
	id_avion INT NOT NULL,
	origen INT NOT NULL,
	destino INT NOT NULL,
	id_piloto INT NOT NULL,
	fecha_inicio DATETIME NOT NULL,
	fecha_fin DATETIME NOT NULL,

	CONSTRAINT fk_escala_vuelo FOREIGN KEY (id_vuelo) REFERENCES Vuelo(id_vuelo)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT fk_escala_avion FOREIGN KEY (id_avion) REFERENCES Avion(id_avion)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT fk_escala_origen FOREIGN KEY (origen) REFERENCES Aeropuertos(id_aeropuerto)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT fk_escala_destino FOREIGN KEY (destino) REFERENCES Aeropuertos(id_aeropuerto)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT fk_escala_trabajador FOREIGN KEY (id_piloto) REFERENCES Trabajador(codigo_trabajador)
	ON DELETE CASCADE
	ON UPDATE CASCADE
)

/*
	El listado de trabajadores que esta en el vuelo
*/
CREATE TABLE Tripulacion (
	codigo_trabajador INT NOT NULL,
	id_vuelo INT NOT NULL,

	CONSTRAINT fk_tripulacion_trabajador FOREIGN KEY (codigo_trabajador) REFERENCES Trabajador(codigo_trabajador)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT fk_tripulacion_vuelo FOREIGN KEY (id_vuelo) REFERENCES Vuelo(id_vuelo)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT pk_tripulacion PRIMARY KEY (codigo_trabajador, id_vuelo)
)

/*
	Lleva registro de las clases registradas para los aviones
*/
CREATE TABLE Clase(
	id_clase INT PRIMARY KEY IDENTITY(1,5),
	id_avion INT NOT NULL,
	tipo VARCHAR(50) NOT NULL,
	cantidad_pasajeros INT NOT NULL,

	CONSTRAINT fk_clase_avion FOREIGN KEY(id_avion) REFERENCES Avion(id_avion)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT ck_tipoclase CHECK (tipo = 'Primera' OR tipo = 'Economica' OR tipo = 'Ejecutiva' )
)

/*
	Luego de confirmar se emite el boleto (inserta en esta tabla)
*/
CREATE TABLE Boletos(
	numero_boleto INT PRIMARY KEY IDENTITY(1,1),
	id_avion INT NOT NULL,
	id_cliente INT NOT NULL,
	id_escala INT NOT NULL,
	id_clase INT NOT NULL,
	numero_asiento INT NOT NULL,

	CONSTRAINT fk_boletos_avion FOREIGN KEY (id_avion) REFERENCES Avion(id_avion)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT fk_boletos_cliente FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT fk_boletos_escala FOREIGN KEY (id_escala) REFERENCES Escala(id_escala)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT fk_boletos_clase FOREIGN KEY (id_clase) REFERENCES Clase(id_clase)
	ON DELETE CASCADE
	ON UPDATE CASCADE
)

/*
	Tiene registro de las plataformas o lugares en los cuales se pueden hacer transacciones
	Por ejemplo una app, una plataforma web, sucursales, etc
*/
CREATE TABLE Plataforma(
	id_plataforma INT PRIMARY KEY,
	nombre VARCHAR(50) NOT NULL
)

/*
	Reservas existentes para los asientos disponibles a la fecha actual
	Luego de eso se van a HistorialReservas
*/
CREATE TABLE Reservas(
	id_reserva INT PRIMARY KEY IDENTITY(1, 1),
	num_registro INT NOT NULL,
	id_vuelo INT NOT NULL,
	estado varchar(50) not null,
	id_clase INT NOT NULL,
	id_avion INT NOT NULL,
	precio DECIMAL,
	descuento DECIMAL,
	plataforma INT NOT NULL,
	id_asiento VARCHAR(10) NOT NULL,

	CONSTRAINT fk_reserva_clase FOREIGN KEY (id_clase) REFERENCES Clase(id_clase)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT fk_reserva_avion FOREIGN KEY (id_avion) REFERENCES Avion(id_avion)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT fk_reserva_vuelo FOREIGN KEY (id_vuelo) REFERENCES Vuelo(id_vuelo)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT fk_reserva_plataforma FOREIGN KEY (plataforma) REFERENCES Plataforma(id_plataforma)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT fk_reserva_asiento FOREIGN KEY (Asientos) REFERENCES Asientos(id_asiento)
	ON DELETE CASCADE
	ON UPDATE CASCADE
)

/*
	Tabla para el historial de las reservas, cancelaciones y personas en cola
*/
CREATE TABLE HistorialReservas(
	id_reserva INT PRIMARY KEY,
	num_registro INT NOT NULL,
	id_vuelo INT NOT NULL,
	estado varchar(50) not null,
	id_clase INT NOT NULL,
	id_avion INT NOT NULL,
	precio DECIMAL,
	descuento DECIMAL,
	plataforma INT NOT NULL,
	id_asiento VARCHAR(10) NOT NULL
)

/*
	Registro de la informacion de los asientos disponibles por avion
*/
CREATE TABLE Asientos(
	id_asiento VARCHAR(10) NOT NULL,
	id_avion INT NOT NULL, 
	id_clase INT NOT NULL,
	informacion_extra VARCHAR(MAX),
	CONSTRAINT fk_asientos_clase FOREIGN KEY (id_avion, id_clase) REFERENCES Clase(id_clase, id_avion)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT pk_asientos PRIMARY KEY (id_asiento, id_avion, id_clase)
)